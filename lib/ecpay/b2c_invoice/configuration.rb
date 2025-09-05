# frozen_string_literal: true

module Ecpay
  class B2CInvoice
    class Configuration
      attr_accessor :merchant_id, :hash_key, :hash_iv, :environment

      def initialize
        @environment = :sandbox
      end

      def sandbox?
        @environment == :sandbox
      end

      def production?
        @environment == :production
      end

      def api_url
        if sandbox?
          "https://einvoice-stage.ecpay.com.tw"
        else
          "https://einvoice.ecpay.com.tw"
        end
      end
    end

    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end