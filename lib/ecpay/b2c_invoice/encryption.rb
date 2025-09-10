# frozen_string_literal: true

require "openssl"
require "base64"
require "json"
require "cgi"

module Ecpay
  class B2CInvoice
    class Encryption
      def self.encrypt_data(data, hash_key, hash_iv)
        json_data = data.to_json
        url_encoded_data = CGI.escape(json_data)

        cipher = OpenSSL::Cipher.new("aes-128-cbc")
        cipher.encrypt
        cipher.key = hash_key
        cipher.iv = hash_iv

        encrypted = cipher.update(url_encoded_data) + cipher.final
        Base64.strict_encode64(encrypted)
      end

      def self.decrypt_data(encrypted_data, hash_key, hash_iv)
        encrypted_bytes = Base64.strict_decode64(encrypted_data)

        cipher = OpenSSL::Cipher.new("aes-128-cbc")
        cipher.decrypt
        cipher.key = hash_key
        cipher.iv = hash_iv

        decrypted = cipher.update(encrypted_bytes) + cipher.final
        url_decoded_data = CGI.unescape(decrypted)
        JSON.parse(url_decoded_data)
      end
    end
  end
end
