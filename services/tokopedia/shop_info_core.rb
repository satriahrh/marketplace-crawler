module Services
  module Tokopedia
    class ShopInfoCore < Services::Tokopedia::Base
      def initialize(shop_domain = 'fluffy')
        super()
        @request["Referer"] = "https://www.tokopedia.com/#{shop_domain}"
        gql = File.open './graphql/shop_info_core.graphql'
        query = gql.read
        @request.body = JSON.dump(
          [
            {
              operationName: "ShopInfoCore",
              variables: {id: 0, domain: shop_domain},
              query: query
            }
          ]
        )
      end
    end
  end
end
