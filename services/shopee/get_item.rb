module Services
  module Shopee
    class GetItem < Services::Shopee::Base
      def initialize(shop_id, item_id)
        super()
        @uri = URI.parse("https://shopee.co.id/api/v2/item/get?itemid=#{item_id}&shopid=#{shop_id}")
      end

      def prepare_uri
        @uri
      end

      def call
        resp = super
        resp&.dig 'item'
      end
    end
  end
end
