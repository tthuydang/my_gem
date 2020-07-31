require 'nokogiri'
require 'httparty'
require 'open-uri'
require 'spreadsheet'
require 'byebug'

class TomosiaAmanaplusCrawl
  URL = "https://plus.amanaimages.com/items/search/"

  def run(keyword)
    unparsed_page = HTTParty.get("#{URL}/#{keyword}")
    parsed_page = Nokogiri::HTML(unparsed_page)

    pages = parsed_page.css("div.c-paginate__nums").css('a').last.text.to_i # tổng số page
    images_listings = parsed_page.css("div.p-search-result__body") # danh sách các thẻ div chứa image

    images = getPaginationImages(images_listings, pages, keyword)
    downloadImages(images, "F:/Ruby/My Gem/downloads", 4)
    writeToExcel(images, "F:/Ruby/My Gem/downloads")
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
        # puts "#{i += 1}: #{src}"
      end
  
      curr_page += 1
    end
    images
  end

  # tải hình và cập nhật lại size
  def downloadImages(images, destination, n)
    if n <= images.size
      File.size('./tomosia_amanaplus_crawl.rb')
      for i in 0..(n - 1) do
        open(images[i][:url]) do |image|
          File.open("#{destination}/#{images[i][:url].split('/').last}", "wb") do |file|
            file.write(image.read) # lưu hình ảnh
            images[i][:size] = image.size # cập nhật lại size trong mảng images
          end
        end # end open
      end # end for
    end # end if
  end

  def writeToExcel(images, destination)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    sheet1.row(0).concat %w{Title Url Size Extension}
    i = 0
    images.each do |img|
      sheet1.row(i += 1).push img[:title], img[:url], img[:size], img[:extension]
    end

    book.write 'F:/Ruby/My Gem/YeuNgucLep.xls'
  end

end

# tomosia_amanaplus_crawl "hoian" --destination "C:\Users\NhatHuy\Pictures" --number=100
TomosiaAmanaplusCrawl.new.run("heo")  # hoian
