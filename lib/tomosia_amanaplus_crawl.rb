require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper(keyword)
  unparsed_page = HTTParty.get("https://plus.amanaimages.com/items/search/#{keyword}")
  parsed_page = Nokogiri::HTML(unparsed_page)
  images_listings = parsed_page.css("div.p-item-thumb__content")

  images = Array.new

  pages = parsed_page.css("div.c-paginate__nums").css('a').last.text.to_i # tổng số page
  # text_total = parsed_page.css("h1.p-search-result__ttl").text  # chuỗi chứa tổng items. Vd: 「heo」の素材:230件（1 - 100件を表示）
  # total = text_total.split(' ')[0][keyword.length + 6, text_total.length - 4].chop.chop.chop  # tổng số item của tất cả các page
  # total = total.gsub(',', '').to_i  # bỏ dấu phẩy của dãy số

  i = 0
  curr_page = 1
  while curr_page <= pages
    puts "crawling page #{curr_page}"

    pagination_unparsed_page = HTTParty.get("https://plus.amanaimages.com/items/search/#{keyword}?page=#{curr_page}")
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
    pagination_images_listings = pagination_parsed_page.css("div.p-item-thumb__content")

    pagination_images_listings.each do |img|
      src = img.css('img').attr('data-src').nil? == true ? img.css('img').attr('src') : img.css('img').attr('data-src')
      current_image = {
        title: img.css('a')[1].attr('title'),
        url: src.to_s,
        size: 'unknow',
        extension: ".#{src.to_s.split('.').last}"
      }
      images << current_image
      puts "#{i += 1}: #{src}"
    end

    curr_page += 1
  end
end

scraper("heo")
