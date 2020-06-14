module Services
  module Tokopedia
    class ShopProducts < Services::Tokopedia::Base
      def initialize(shop_domain='fluffy', shop_id='2925242')
        super()
        @request["Referer"] = "https://www.tokopedia.com/#{shop_domain}?source=universe&st=product&keyword=&sort=8"
        @request["X-Device"] = "default_v3"
        gql = File.open './graphql/shop_products.graphql'
        @query = gql.read

        @page = 1
        @shop_id = shop_id
      end

      def call
        update_request_body
        resp = super
        last_count = resp[0]['data']['GetShopProduct']['data'].count
        while last_count == 80
          @page += 1
          update_request_body
          new_resp = super
          resp[0]['data']['GetShopProduct']['data'] += new_resp[0]['data']['GetShopProduct']['data']
          last_count = new_resp[0]['data']['GetShopProduct']['data'].count
        end
        resp
      end

      def update_request_body
        @request.body = JSON.dump(
          [
            {
              operationName: "ShopProducts",
              variables: {
                sid: @shop_id,
                page: @page,
                perPage: 80,
                keyword: "",
                etalaseId: "etalase",
                sort: 8
              },
              query: @query
            }
          ]
        )
      end
    end
  end
end

