require 'nokogiri'
require 'httparty'
require 'byebug'

class TomosiaAmanaplusCrawl
  URL = "https://plus.amanaimages.com/items/search/"

  def run(keyword)
    unparsed_page = HTTParty.get("#{URL}/#{keyword}")
    parsed_page = Nokogiri::HTML(unparsed_page)

    pages = parsed_page.css("div.c-paginate__nums").css('a').last.text.to_i # tổng số page
    images_listings = parsed_page.css("div.p-search-result__body") # danh sách các thẻ div chứa image

    images = getPaginationImages(images_listings, pages, keyword)
  end

  def getPaginationImages(images_listings, pages, keyword)  # lấy tất cả image của các page cộng lại
    images = Array.new
    i = 0
    curr_page = 1
    while curr_page <= pages
      puts "crawling page #{curr_page}......................"
  
      pagination_unparsed_page = HTTParty.get("https://plus.amanaimages.com/items/search/#{keyword}?page=#{curr_page}")
      pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
      pagination_images_listings = pagination_parsed_page.css("div.p-item-thumb")
  
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
    images
  end
end

TomosiaAmanaplusCrawl.new.run("hoian")
