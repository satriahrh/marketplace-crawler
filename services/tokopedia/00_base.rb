require 'net/http'
require 'uri'
require 'json'

module Services
  module Tokopedia
    class Base
      def initialize()
        @uri = URI.parse("https://gql.tokopedia.com/")
        @request = Net::HTTP::Post.new(@uri)
        @request.content_type = "application/json"
        @request["Accept"] = "*/*"
        @request["Host"] = "gql.tokopedia.com"
        @request["Accept-Language"] = "en-us"
        @request["Origin"] = "https://www.tokopedia.com"
        @request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"
        @request["Cookie"] = ENV['TOKOPEDIA_COOKIE']
        @request["X-Tkpd-Lite-Service"] = "zeus"
        @request["X-Source"] = "tokopedia-lite"
      end

      def call
        req_options = {
          use_ssl: @uri.scheme == "https",
        }

        response = Net::HTTP.start(@uri.hostname, @uri.port, req_options) do |http|
          http.request(@request)
        end

        JSON.parse(response.body) rescue nil
      end
    end
  end
end

