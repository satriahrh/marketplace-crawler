require './main.rb'

shop_id = 52587699
items = Services::Shopee.search_items shop_id

require "csv"
CSV.open("shopee_fluffy.csv", "w", :headers => %w(kode corak pcsSold name_0 sold_0 name_1 sold_1 name_2 sold_2 name_3 sold_3 name_4 sold_4 name_5 sold_5  urutan), :write_headers => true) do |table|
  counter = 0
  items.each do |item|
    puts "item #{counter}\tfrom #{items.count}"
    counter += 1
    item_id = item&.dig('itemid')
    item_detail = Services::Shopee.get_item shop_id, item_id

    info = {
      'name' => item_detail&.dig('name'),
      'itemSold' => item_detail&.dig('historical_sold'),
      'rating' => item_detail&.dig('item_rating')&.dig('rating_star'),
      'ratingCount' => item_detail&.dig('item_rating')&.dig('rating_count')&.first,
      'description' => item_detail&.dig('description'),
    }

    urutan = []
    puts item_detail&.dig('models')&.to_json
    item_detail&.dig('models').each_with_index do |model, i|
      info["name_#{i}"] = model&.dig('name')
      info["sold_#{i}"] = model&.dig('sold')&.to_i
      urutan.each_with_index do |urut, j|
        if info["sold_#{urut}"] < info["sold_#{i}"]
          urutan.insert(j, i)
          break
        end
      end
      urutan << i unless urutan.include? i
    end
    info['urutan'] = urutan.join(' -> ')

    info['url'] = "https://shopee.co.id/#{info['name'].gsub(' ', '-')}-i.#{shop_id}.#{item_id}"

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

    # pcs
    pcs = info['description'].match /\d( ?)pcs/i
    begin
      pcs = pcs[0]&.to_i
    rescue
      pcs = 0
    end
    info['pcs'] = pcs

    info['pcsSold'] = info['pcs']&.to_i * info['itemSold']&.to_i

    table << info
  end
end