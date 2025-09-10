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
      def issue_invoice(invoice_data)
        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.now.to_i
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

        parse_response(response, request_payload: invoice_data)
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
            Timestamp: Time.now.to_i
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

        parse_response(response, request_payload: data)
      end

      # 前置作業／字軌與配號設定 (新增字軌)
      def add_invoice_word_setting(setting_data)
        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.now.to_i
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

        parse_response(response, request_payload: setting_data)
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
            Timestamp: Time.now.to_i
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

        parse_response(response, request_payload: data)
      end

      # 前置作業／查詢字軌
      def get_invoice_word_setting(query_data)
        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.now.to_i
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

        parse_response(response, request_payload: query_data)
      end

      # 發票作業／取得發票列印網址
      def get_invoice_print_url(invoice_no, invoice_date, print_style: 1, is_showing_detail: 1)
        data = {
          MerchantID: @config.merchant_id,
          InvoiceNo: invoice_no,
          InvoiceDate: invoice_date,
          PrintStyle: print_style,
          IsShowingDetail: is_showing_detail
        }

        request_data = {
          MerchantID: @config.merchant_id,
          RqHeader: {
            Timestamp: Time.now.to_i
          },
          Data: Encryption.encrypt_data(data, @config.hash_key, @config.hash_iv)
        }

        response = self.class.post(
          "/B2CInvoice/InvoicePrint",
          body: request_data.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        parse_response(response, request_payload: data)
      end

      private

      def parse_response(response, request_payload: nil)
        return { error: "HTTP Error: #{response.code}", status_code: response.code } unless response.success?

        body = response.parsed_response

        if body["Data"]
          decrypted_data = Encryption.decrypt_data(body["Data"], @config.hash_key, @config.hash_iv)
          {
            success: body["TransCode"] == 1,
            data: decrypted_data,
            trans_code: body["TransCode"],
            trans_msg: body["TransMsg"],
            request_payload: request_payload
          }
        else
          {
            success: false,
            error: body["TransMsg"] || "Unknown error",
            trans_code: body["TransCode"],
            status_code: response.code,
            request_payload: request_payload
          }
        end
      rescue JSON::ParserError
        { error: "Invalid JSON response", request_payload: request_payload }
      rescue StandardError => e
        { error: "Unexpected error: #{e.message}", request_payload: request_payload }
      end
    end
  end
end
