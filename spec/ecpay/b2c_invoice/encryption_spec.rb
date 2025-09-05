# frozen_string_literal: true

RSpec.describe Ecpay::B2CInvoice::Encryption do
  let(:hash_key) { "1234567890123456" } # 16 bytes for AES-128
  let(:hash_iv) { "abcdefghijklmnop" }  # 16 bytes for AES-128
  let(:test_data) { { "test" => "data", "number" => 123 } }

  describe ".encrypt_data" do
    it "encrypts data and returns base64 encoded string" do
      encrypted = described_class.encrypt_data(test_data, hash_key, hash_iv)
      
      expect(encrypted).to be_a(String)
      expect(encrypted).not_to be_empty
      expect { Base64.strict_decode64(encrypted) }.not_to raise_error
    end

    it "produces different output for different inputs" do
      data1 = { "key" => "value1" }
      data2 = { "key" => "value2" }
      
      encrypted1 = described_class.encrypt_data(data1, hash_key, hash_iv)
      encrypted2 = described_class.encrypt_data(data2, hash_key, hash_iv)
      
      expect(encrypted1).not_to eq(encrypted2)
    end
  end

  describe ".decrypt_data" do
    it "decrypts encrypted data back to original format" do
      encrypted = described_class.encrypt_data(test_data, hash_key, hash_iv)
      decrypted = described_class.decrypt_data(encrypted, hash_key, hash_iv)
      
      expect(decrypted).to eq(test_data)
    end

    it "raises error for invalid base64 data" do
      expect {
        described_class.decrypt_data("invalid_base64!", hash_key, hash_iv)
      }.to raise_error(ArgumentError)
    end

    it "raises error for wrong decryption key" do
      encrypted = described_class.encrypt_data(test_data, hash_key, hash_iv)
      wrong_key = "wrong_key_123456"
      
      expect {
        described_class.decrypt_data(encrypted, wrong_key, hash_iv)
      }.to raise_error(OpenSSL::Cipher::CipherError)
    end
  end

  describe ".generate_timestamp" do
    it "returns timestamp in correct format" do
      timestamp = described_class.generate_timestamp
      
      expect(timestamp).to match(/\A\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\z/)
    end

    it "returns current time" do
      freeze_time = Time.new(2023, 12, 1, 15, 30, 45)
      allow(Time).to receive(:now).and_return(freeze_time)
      
      timestamp = described_class.generate_timestamp
      expect(timestamp).to eq("2023-12-01 15:30:45")
    end
  end

  describe "round-trip encryption/decryption" do
    it "maintains data integrity for complex nested data" do
      complex_data = {
        "customer" => {
          "name" => "王小明",
          "email" => "test@example.com"
        },
        "items" => [
          { "name" => "商品A", "price" => 100 },
          { "name" => "商品B", "price" => 200 }
        ],
        "total" => 300,
        "unicode" => "測試中文字符 🎉"
      }
      
      encrypted = described_class.encrypt_data(complex_data, hash_key, hash_iv)
      decrypted = described_class.decrypt_data(encrypted, hash_key, hash_iv)
      
      expect(decrypted).to eq(complex_data)
    end
  end
end