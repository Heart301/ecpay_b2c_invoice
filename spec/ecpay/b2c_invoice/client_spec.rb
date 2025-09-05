# frozen_string_literal: true

RSpec.describe Ecpay::B2CInvoice::Client do
  let(:config) do
    Ecpay::B2CInvoice::Configuration.new.tap do |c|
      c.merchant_id = "test_merchant"
      c.hash_key = "1234567890123456"
      c.hash_iv = "abcdefghijklmnop"
      c.environment = :sandbox
    end
  end
  
  let(:client) { described_class.new(config) }
  
  let(:invoice_data) do
    {
      RelateNumber: "ORDER_20231201001",
      CustomerName: "王小明",
      CustomerEmail: "customer@example.com",
      SalesAmount: 1000,
      Items: [
        {
          ItemName: "商品A",
          ItemCount: 1,
          ItemWord: "個",
          ItemPrice: 1000,
          ItemAmount: 1000
        }
      ],
      TaxType: "1",
      Print: "0",
      Donation: "0"
    }
  end

  describe "#initialize" do
    it "uses provided config" do
      expect(client.instance_variable_get(:@config)).to eq(config)
    end

    it "uses default configuration when none provided" do
      allow(Ecpay::B2CInvoice).to receive(:configuration).and_return(config)
      client_without_config = described_class.new
      expect(client_without_config.instance_variable_get(:@config)).to eq(config)
    end

    it "sets base URI from config" do
      expect(described_class.base_uri).to eq("https://einvoice-stage.ecpay.com.tw")
    end
  end

  describe "#create_invoice" do
    let(:successful_response_data) do
      {
        "RtnCode" => 1,
        "RtnMsg" => "Success",
        "InvoiceNo" => "AB12345678",
        "InvoiceDate" => "2023-12-01",
        "RandomNumber" => "1234"
      }
    end

    let(:encrypted_response_data) do
      Ecpay::B2CInvoice::Encryption.encrypt_data(
        successful_response_data,
        config.hash_key,
        config.hash_iv
      )
    end

    before do
      allow(Ecpay::B2CInvoice::Encryption).to receive(:generate_timestamp).and_return("2023-12-01 10:00:00")
    end

    context "when API returns successful response" do
      before do
        stub_request(:post, "https://einvoice-stage.ecpay.com.tw/B2CInvoice/Issue")
          .to_return(
            status: 200,
            body: {
              TransCode: 1,
              TransMsg: "Success",
              Data: encrypted_response_data
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns successful response with decrypted data" do
        result = client.create_invoice(invoice_data)
        
        expect(result[:success]).to be true
        expect(result[:trans_code]).to eq(1)
        expect(result[:trans_msg]).to eq("Success")
        expect(result[:data]).to eq(successful_response_data)
      end

      it "sends correctly formatted request" do
        client.create_invoice(invoice_data)
        
        expect(WebMock).to have_requested(:post, "https://einvoice-stage.ecpay.com.tw/B2CInvoice/Issue") { |req|
          body = JSON.parse(req.body)
          expect(body["MerchantID"]).to eq("test_merchant")
          expect(body["RqHeader"]["Timestamp"]).to eq(Time.parse("2023-12-01 10:00:00").to_i)
          expect(body["Data"]).to be_a(String)
          true
        }
      end
    end

    context "when API returns error response without encrypted data" do
      before do
        stub_request(:post, "https://einvoice-stage.ecpay.com.tw/B2CInvoice/Issue")
          .to_return(
            status: 200,
            body: {
              TransCode: 0,
              TransMsg: "Invalid merchant ID"
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns error response" do
        result = client.create_invoice(invoice_data)
        
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Invalid merchant ID")
        expect(result[:trans_code]).to eq(0)
      end
    end

    context "when HTTP request fails" do
      before do
        stub_request(:post, "https://einvoice-stage.ecpay.com.tw/B2CInvoice/Issue")
          .to_return(status: 500)
      end

      it "returns HTTP error" do
        result = client.create_invoice(invoice_data)
        
        expect(result[:error]).to eq("HTTP Error: 500")
      end
    end

    context "when response contains invalid JSON" do
      before do
        stub_request(:post, "https://einvoice-stage.ecpay.com.tw/B2CInvoice/Issue")
          .to_return(
            status: 200,
            body: "invalid json",
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns JSON parse error" do
        result = client.create_invoice(invoice_data)
        
        expect(result[:error]).to eq("Invalid JSON response")
      end
    end

    context "when decryption fails" do
      before do
        stub_request(:post, "https://einvoice-stage.ecpay.com.tw/B2CInvoice/Issue")
          .to_return(
            status: 200,
            body: {
              TransCode: 1,
              TransMsg: "Success",
              Data: "invalid_encrypted_data"
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns decryption error" do
        result = client.create_invoice(invoice_data)
        
        expect(result[:error]).to include("Unexpected error:")
      end
    end
  end
end