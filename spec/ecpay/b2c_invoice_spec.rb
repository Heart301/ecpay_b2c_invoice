# frozen_string_literal: true

RSpec.describe Ecpay::B2CInvoice do
  it "has a version number" do
    expect(Ecpay::VERSION).not_to be nil
  end

  describe "integration test" do
    before do
      Ecpay::B2CInvoice.configure do |config|
        config.merchant_id = "test_merchant_123"
        config.hash_key = "1234567890123456"
        config.hash_iv = "abcdefghijklmnop"
        config.environment = :sandbox
      end
    end

    it "can create client and perform basic operations" do
      client = Ecpay::B2CInvoice::Client.new

      expect(client).to be_an_instance_of(Ecpay::B2CInvoice::Client)
      expect(client.instance_variable_get(:@config).merchant_id).to eq("test_merchant_123")
      expect(client.instance_variable_get(:@config).environment).to eq(:sandbox)
    end

    it "encrypts and decrypts data correctly in full workflow" do
      test_data = {
        "RelateNumber" => "TEST_ORDER_001",
        "CustomerName" => "測試客戶",
        "CustomerEmail" => "test@example.com",
        "SalesAmount" => 1500,
        "Items" => [
          {
            "ItemName" => "測試商品",
            "ItemCount" => 1,
            "ItemWord" => "個",
            "ItemPrice" => 1500,
            "ItemAmount" => 1500
          }
        ]
      }

      encrypted = Ecpay::B2CInvoice::Encryption.encrypt_data(
        test_data,
        Ecpay::B2CInvoice.configuration.hash_key,
        Ecpay::B2CInvoice.configuration.hash_iv
      )

      expect(encrypted).to be_a(String)
      expect(encrypted).not_to be_empty

      decrypted = Ecpay::B2CInvoice::Encryption.decrypt_data(
        encrypted,
        Ecpay::B2CInvoice.configuration.hash_key,
        Ecpay::B2CInvoice.configuration.hash_iv
      )

      expect(decrypted).to eq(test_data)
    end
  end
end