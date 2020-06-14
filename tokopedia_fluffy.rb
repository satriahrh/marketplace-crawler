require './main.rb'
require 'redis'
redis = Redis.new

shop_domain = 'fluffy'

shop_info_core_key = "shop_info_core_#{shop_domain}"
shop_info_core = redis.get(shop_info_core_key)
if shop_info_core
  shop_info_core = JSON.parse(shop_info_core)
else
  shop_info_core = Services::Tokopedia.shop_info_core(shop_domain)
  redis.set(shop_info_core_key, shop_info_core.to_json)
end

shop_id = shop_info_core[0]['data']['shopInfoByID']['result'][0]['shopCore']['shopID']

shop_products_key = "shop_products_#{shop_domain}_#{shop_id}"
shop_products = redis.get(shop_products_key)
if shop_products
  shop_products = JSON.parse(shop_products)
else
  shop_products = Services::Tokopedia.shop_products(shop_domain, shop_id)
  redis.set(shop_products_key, shop_products.to_json)
end

require "csv"
CSV.open("tokopedia_fluffy.csv", "w", :headers => %w(kode corak name pcs itemSold pcsSold countView rating countReview url), :write_headers => true) do |table|
  shop_products[0]['data']['GetShopProduct']['data'].each do |product|
    pdp_info_key = product['product_url']
    pdp_info = redis.get(pdp_info_key)
    if pdp_info
      pdp_info = JSON.parse(pdp_info)
    else
      product_url_splitted = product['product_url'].split '/'
      product_key = product_url_splitted.last
      pdp_info = Services::Tokopedia.pdp_info_query(shop_domain, product_key)
      redis.set(pdp_info_key, pdp_info.to_json)
    end

    info = {
      'sku' => pdp_info[0]['data']['getPDPInfo']['basic']['sku'],
      'name' => pdp_info[0]['data']['getPDPInfo']['basic']['name'],
      'url' => pdp_info[0]['data']['getPDPInfo']['basic']['url'],
      'itemSold' => pdp_info[0]['data']['getPDPInfo']['txStats']['itemSold'],
      'countView' => pdp_info[0]['data']['getPDPInfo']['stats']['countView'],
      'rating' => pdp_info[0]['data']['getPDPInfo']['stats']['rating'],
      'countReview' => pdp_info[0]['data']['getPDPInfo']['stats']['countReview'],
      'description' => pdp_info[0]['data']['getPDPInfo']['basic']['description'],
    }

    # pcs
    als = pdp_info[0]['data']['getPDPInfo']['basic']['alias']
    pcs = als.match /\d(-?)pcs/i
    if pcs
      pcs = pcs[0]&.to_i
    else
      pcs = info['description'].match /\d( ?)pcs/i
      begin
        pcs = pcs[0]&.to_i
      rescue
        puts "#{info['alias']} #{info['description']}"
        pcs = 0
      end
    end
    info['pcs'] = pcs

    info['pcsSold'] = info['pcs']&.to_i * info['itemSold']&.to_i

    # kode
    kode = info['description'].match /kode : .+$/i
    if kode
      kode = kode[0][7...]
      info['kode'] = kode
    end

    # corak
    corak = info['description'].match /corak : .+$/i
    if corak
      info['corak'] = corak[0][8...]
    end

    table << info
  end
end