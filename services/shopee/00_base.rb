require 'net/http'
require 'uri'
require 'json'
require 'redis'

module Services
  module Shopee
    class Base
      def initialize
        @request_items = {
          "Accept": "*/*",
          "Host": "shopee.co.id",
          "Accept-Language": "en-us",
          "Connection": "keep-alive",
          "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15",
          "Cookie": ENV['SHOPEE_COOKIE'],
          "X-Requested-With": "XMLHttpRequest",
          "X-Api-Source": "pc",
          "X-Shopee-Language": "id",
        }
        @redis = Redis.new
      end

      def prepare_uri
        raise NotImplementedError
      end

      def call
        @uri = prepare_uri
        body = @redis&.get @uri.to_s
        if body.nil?
          puts "requesting #{@uri}"
          @request = Net::HTTP::Get.new(@uri)
          @request_items.keys.each do |request_item_key|
            @request[request_item_key] = @request_items[request_item_key]
          end
          req_options = {
            use_ssl: @uri.scheme == "https",
          }

          response = Net::HTTP.start(@uri.hostname, @uri.port, req_options) do |http|
            http.request(@request)
          end

          body = response&.body
          @redis.set @uri.to_s, body
        end

        begin
          json_parse = JSON.parse(body)
        rescue
          puts body
          json_parse = nil
        end
        json_parse
      end
    end
  end
end

