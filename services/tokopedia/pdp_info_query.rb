module Services
  module Tokopedia
    class PdpInfoQuery < Services::Tokopedia::Base
      def initialize(shop_domain = 'fluffy', product_key = 'baju-pendek-anak-putih-fluffy-1-2-3-bdx-pth-isi-4pcs-18-24-bulan')
        super()
        @request["Referer"] = "https://www.tokopedia.com/#{shop_domain}/#{product_key}"
        @request["X-Tkpd-Akamai"] = "product_info"
        gql = File.open './graphql/pdp_info_query.graphql'
        query = gql.read
        @request.body = JSON.dump(
          [
            {
              operationName: "PDPInfoQuery",
              variables: {
                shopDomain: shop_domain,
                productKey: product_key
              },
              query: query
            }
          ]
        )
      end
    end
  end
end
