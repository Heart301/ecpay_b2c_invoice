# frozen_string_literal: true

RSpec.describe Ecpay::B2CInvoice::Encryption do
  let(:hash_key) { "ejCk326UnaZWKisg" } # 16 bytes for AES-128
  let(:hash_iv) { "q9jcZX8Ib9LM8wYk" }  # 16 bytes for AES-128
  let(:test_data) { { "Name" => "Test","ID" => "A123456789" } }

  describe ".encrypt_data" do
    it "encrypts data and returns base64 encoded string" do
      encrypted = described_class.encrypt_data(test_data, hash_key, hash_iv)
      puts "Test Data: #{test_data}"
      puts "Encrypted: #{encrypted}"
      expect(encrypted).to eq('uvI4yrErM37XNQkXGAgRgJAgHn2t72jahaMZzYhWL1HmvH4WV18VJDP2i9pTbC+tby5nxVExLLFyAkbjbS2Dvg==')
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
