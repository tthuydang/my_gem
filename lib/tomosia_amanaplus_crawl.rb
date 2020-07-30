require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper(keyword)
  unparsed_page = HTTParty.get("https://plus.amanaimages.com/items/search/#{keyword}")
  parsed_page = Nokogiri::HTML(unparsed_page)
  images = parsed_page.css("div.p-item-thumb__content")

  i = 0
  images.each do |img|
    if img.css('img').attr('data-src').nil?
      puts "#{i += 1}: #{img.css('img').attr('src')}"
    else
      puts "#{i += 1}: #{img.css('img').attr('data-src')}"
    end
  end

  # byebug
end

scraper("chicken")
