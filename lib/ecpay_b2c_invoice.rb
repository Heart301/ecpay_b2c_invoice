# frozen_string_literal: true

require_relative "ecpay_b2c_invoice/version"
require_relative "ecpay_b2c_invoice/configuration"
require_relative "ecpay_b2c_invoice/encryption"
require_relative "ecpay_b2c_invoice/client"

module EcpayB2cInvoice
  class Error < StandardError; end
end