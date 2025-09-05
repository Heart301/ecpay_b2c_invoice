# frozen_string_literal: true

require_relative "version"
require_relative "b2c_invoice/configuration"
require_relative "b2c_invoice/encryption"
require_relative "b2c_invoice/client"

module Ecpay
  class B2CInvoice
    class Error < StandardError; end
  end
end