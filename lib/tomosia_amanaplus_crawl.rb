require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper(keyword)
  unparsed_page = HTTParty.get("https://plus.amanaimages.com/items/search/#{keyword}")
  parsed_page = Nokogiri::HTML(unparsed_page)
  images_listings = parsed_page.css("div.p-item-thumb__content")

  i = 0
  src = nil
  images = Array.new

  images_listings.each do |img|
    src = img.css('img').attr('data-src').nil? == true ? img.css('img').attr('src') : img.css('img').attr('data-src')
    current_image = {
      title: img.css('a')[1].attr('title'),
      url: src.to_s,
      size: 'unknow',
      extension: ".#{src.to_s.split('.').last}"
    }
    images << current_image
    puts current_image
  end
end

scraper("heo")
