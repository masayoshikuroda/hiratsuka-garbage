require 'date'
require 'open-uri'
require 'nokogiri'

class GarbagePdf
  attr_accessor :pdf

  PDF_FILE_NAME = "garbage.pdf"

  def initialize(date, area)
    pdf_url = GarbagePdf::get_pdf_url(date, area)
    @pdf = GarbagePdf::download_link(pdf_url)
    File.write(PDF_FILE_NAME, @pdf)
  end

  def self.get_pdf_url(date, area)
    return 'http://www.city.hiratsuka.kanagawa.jp/common/100023350.pdf'
  end

  def self.download_link(pdfurl)
    open(pdfurl, 'rb') do |file|
      return file.read
    end
  end
end

