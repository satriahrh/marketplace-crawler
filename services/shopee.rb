require_relative 'shopee/00_base'
require_relative 'shopee/get_item'
require_relative 'shopee/search_items'

module Services
  module Shopee
    module_function

    def get_item(*args); Services::Shopee::GetItem.new(*args).call; end
    def search_items(*args); Services::Shopee::SearchItems.new(*args).call; end
  end
end
