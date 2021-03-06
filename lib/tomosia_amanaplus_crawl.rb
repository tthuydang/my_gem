require 'nokogiri'
require 'httparty'
require 'open-uri'
require 'fileutils'
require 'spreadsheet'

module TomosiaAmanaplusCrawl
  class Crawler
    URL = "https://plus.amanaimages.com/items/search/"

    def run(keyword, destination)
      unparsed_page = HTTParty.get("#{URL}/#{keyword}")
      parsed_page = Nokogiri::HTML(unparsed_page)

      pages = parsed_page.css("div.c-paginate__nums").css('a').last.text.to_i # tổng số page
      images_listings = parsed_page.css("div.p-search-result__body") # danh sách các thẻ div chứa image

      images = getPaginationImages(images_listings, pages, keyword)
      downloadImages(images, destination)
      writeToExcel(images, destination)
    end

    def getPaginationImages(images_listings, pages, keyword)  # lấy tất cả image của các page cộng lại
      images = Array.new
      i = 0
      curr_page = 1
      while curr_page <= pages
        puts "Crawling page #{curr_page}..........."
    
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
    def downloadImages(images, destination)
      path = "#{destination}/Downloads"       # lưu hình ở folder Downloads
      Dir.mkdir path unless File.exist? path

      threads = []
      print "\nDownloading"
      images.each do |curr_image|
        threads << Thread.new(curr_image) {
          open(curr_image[:url]) do |image|
            File.open("#{path}/#{curr_image[:url].split('/').last}", "a+") do |file|
              file.write(image.read) # lưu hình ảnh
              curr_image[:size] = image.size # cập nhật lại size trong mảng images
              print "."
            end
          end # end open
        }
      end
      threads.each { |t| t.join }
      puts "\nDownloaded."
    end

    def writeToExcel(images, destination)
      path = "#{destination}/File Excel"      # lưu file ở folder File Excel
      Dir.mkdir path unless File.exist? path

      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet

      i = 0
      sheet1.row(0).concat %w{Title Url Size(bytes) Extension}
      puts "Writing..........."
      images.each do |img|
        sheet1.row(i += 1).push img[:title], img[:url], img[:size], img[:extension]
      end
      puts "Writed."

      book.write "#{path}/YeuNgucLep.xls"
    end

  end
end

# tomosia_amanaplus_crawl "hoian" --destination "C:\Users\NhatHuy\Pictures" --number=100
TomosiaAmanaplusCrawl::Crawler.new.run("hoian", "./")  # hội an
