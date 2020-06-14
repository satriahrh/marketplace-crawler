require_relative 'tokopedia/00_base'
require_relative 'tokopedia/pdp_info_query'
require_relative 'tokopedia/shop_products'
require_relative 'tokopedia/shop_info_core'

module Services
  module Tokopedia
    module_function

    def pdp_info_query(*args); Services::Tokopedia::PdpInfoQuery.new(*args).call; end
    def shop_products(*args); Services::Tokopedia::ShopProducts.new(*args).call; end
    def shop_info_core(*args); Services::Tokopedia::ShopInfoCore.new(*args).call; end
  end
end
