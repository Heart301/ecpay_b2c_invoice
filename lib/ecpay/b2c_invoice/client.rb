# frozen_string_literal: true

require "httparty"

module Ecpay
  class B2CInvoice
    class Client
      include HTTParty

      def initialize(config = nil)
        @config = config || Ecpay::B2CInvoice.configuration
        self.class.base_uri @config.api_url
      end

      # 發票作業 ／ 開立發票 / 一般開立發票
      def create_invoice(invoice_data)
        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.current.to_i
          },
          Data: Encryption.encrypt_data(invoice_data, @config.hash_key, @config.hash_iv)
        }

        response = self.class.post(
          "/B2CInvoice/Issue",
          body: request_data.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        parse_response(response)
      end

      # 前置作業／查詢財政部配號結果
      def get_gov_invoice_word_setting(invoice_year)
        data = {
          MerchantID: @config.merchant_id,
          InvoiceYear: invoice_year
        }

        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.current.to_i
          },
          Data: Encryption.encrypt_data(data, @config.hash_key, @config.hash_iv)
        }

        response = self.class.post(
          "/B2CInvoice/GetGovInvoiceWordSetting",
          body: request_data.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        parse_response(response)
      end

      # 前置作業／字軌與配號設定
      def add_invoice_word_setting(setting_data)
        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.current.to_i
          },
          Data: Encryption.encrypt_data(setting_data, @config.hash_key, @config.hash_iv)
        }

        response = self.class.post(
          "/B2CInvoice/AddInvoiceWordSetting",
          body: request_data.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        parse_response(response)
      end

      # 前置作業／設定字軌號碼狀態
      def update_invoice_word_status(track_id, invoice_status)
        data = {
          TrackID: track_id,
          InvoiceStatus: invoice_status
        }

        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.current.to_i
          },
          Data: Encryption.encrypt_data(data, @config.hash_key, @config.hash_iv)
        }

        response = self.class.post(
          "/B2CInvoice/UpdateInvoiceWordStatus",
          body: request_data.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        parse_response(response)
      end

      # 前置作業／查詢字軌
      def get_invoice_word_setting(query_data)
        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.current.to_i
          },
          Data: Encryption.encrypt_data(query_data, @config.hash_key, @config.hash_iv)
        }

        response = self.class.post(
          "/B2CInvoice/GetInvoiceWordSetting",
          body: request_data.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        parse_response(response)
      end

      private

      def parse_response(response)
        return { error: "HTTP Error: #{response.code}" } unless response.success?

        body = response.parsed_response

        if body["Data"]
          decrypted_data = Encryption.decrypt_data(body["Data"], @config.hash_key, @config.hash_iv)
          {
            success: body["TransCode"] == 1,
            data: decrypted_data,
            trans_code: body["TransCode"],
            trans_msg: body["TransMsg"]
          }
        else
          {
            success: false,
            error: body["TransMsg"] || "Unknown error",
            trans_code: body["TransCode"]
          }
        end
      rescue JSON::ParserError
        { error: "Invalid JSON response" }
      rescue StandardError => e
        { error: "Unexpected error: #{e.message}" }
      end
    end
  end
end
