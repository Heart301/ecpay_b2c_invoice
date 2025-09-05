# frozen_string_literal: true

RSpec.describe Ecpay::B2CInvoice::Configuration do
  describe "#initialize" do
    it "sets default environment to sandbox" do
      config = described_class.new
      expect(config.environment).to eq(:sandbox)
    end
  end

  describe "#sandbox?" do
    it "returns true when environment is sandbox" do
      config = described_class.new
      config.environment = :sandbox
      expect(config).to be_sandbox
    end

    it "returns false when environment is production" do
      config = described_class.new
      config.environment = :production
      expect(config).not_to be_sandbox
    end
  end

  describe "#production?" do
    it "returns true when environment is production" do
      config = described_class.new
      config.environment = :production
      expect(config).to be_production
    end

    it "returns false when environment is sandbox" do
      config = described_class.new
      config.environment = :sandbox
      expect(config).not_to be_production
    end
  end

  describe "#api_url" do
    it "returns sandbox URL when environment is sandbox" do
      config = described_class.new
      config.environment = :sandbox
      expect(config.api_url).to eq("https://einvoice-stage.ecpay.com.tw")
    end

    it "returns production URL when environment is production" do
      config = described_class.new
      config.environment = :production
      expect(config.api_url).to eq("https://einvoice.ecpay.com.tw")
    end
  end

  describe "attribute accessors" do
    let(:config) { described_class.new }

    it "allows setting and getting merchant_id" do
      config.merchant_id = "test_merchant"
      expect(config.merchant_id).to eq("test_merchant")
    end

    it "allows setting and getting hash_key" do
      config.hash_key = "test_key"
      expect(config.hash_key).to eq("test_key")
    end

    it "allows setting and getting hash_iv" do
      config.hash_iv = "test_iv"
      expect(config.hash_iv).to eq("test_iv")
    end
  end
end

RSpec.describe Ecpay::B2CInvoice do
  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(Ecpay::B2CInvoice::Configuration)
    end

    it "returns the same instance on multiple calls" do
      first_call = described_class.configuration
      second_call = described_class.configuration
      expect(first_call).to be(second_call)
    end
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| described_class.configure(&b) }
        .to yield_with_args(described_class.configuration)
    end

    it "allows setting configuration values" do
      described_class.configure do |config|
        config.merchant_id = "configured_merchant"
        config.environment = :production
      end

      expect(described_class.configuration.merchant_id).to eq("configured_merchant")
      expect(described_class.configuration.environment).to eq(:production)
    end
  end
end