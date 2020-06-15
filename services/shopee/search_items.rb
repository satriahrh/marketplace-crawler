module Services
  module Shopee
    class SearchItems < Services::Shopee::Base
      def initialize(shop_id, limit = 30)
        super()
        @match_id = shop_id
        @limit = limit
        @newest = 0
      end

      def prepare_uri
        URI.parse("https://shopee.co.id/api/v2/search_items/?by=pop&limit=#{@limit}&match_id=#{@match_id}&newest=#{@newest}&order=desc&page_type=shop&version=2")
      end

      def call
        puts "retrieving items from #{@newest} to #{@newest + @limit}"
        resp = super
        items = resp&.dig('items')
        while resp&.dig('items')&.count&.to_i == @limit
          @newest += @limit
          puts "retrieving items from #{@newest} to #{@newest + @limit}"
          resp = super
          new_items = resp&.dig('items')
          new_items = [] if new_items.nil?
          items += new_items
        end

        return [] if items.nil?
        items
      end
    end
  end
end
