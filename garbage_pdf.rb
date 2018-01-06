require 'date'
require 'open-uri'
require 'nokogiri'

class GarbagePdf
  attr_accessor :pdf

   BASE_URL = 'http://www.city.hiratsuka.kanagawa.jp'
   PDF_FILE_NAME = "garbage.pdf"

  def initialize(date, area)
    pdf_url = GarbagePdf::get_pdf_url(date, area)
    @pdf = GarbagePdf::download_link(pdf_url)
    File.write(PDF_FILE_NAME, @pdf)
  end
  
  def self.get_pdf_url(date, area)
    keyowrd = (date.year - 1988).to_s + '年度日本語版'

    keyword = area
    url = BASE_URL + '/kankyo/page-c_01189.html'
    pdf_url = BASE_URL
    html = open(url) do |f| f.read end
    page = Nokogiri::HTML.parse(html, nil, 'UTF-8')
    page.xpath("//a[contains(text(), '%s')]" % keyword).each do |a|
       pdf_url =  BASE_URL + a[:href]
    end
    return pdf_url
  end

  def self.download_link(pdfurl)
    open(pdfurl, 'rb') do |file|
      return file.read
    end
  end
end

