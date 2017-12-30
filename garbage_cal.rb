require 'date'
require 'pdftotext'

class String
  def to_hankaku
    self.tr("０-９", "0-9")
  end

  def to_wday
    self.tr("日月火水木金土", "0-6").to_i
  end
end

class GarbageCalendar
  attr_reader :district, :year
  attr_reader :burnableDaysOfWeek, :burnableStartDate, :burnableEndDate
  attr_reader :petDaysOfWeek, :petStartDate, :petEndDate
  attr_reader :noBurnableDates
  attr_reader :reusableDates

  def initialize(pdf_name)
    @lines = GarbageCalendar::get_pdf_text(pdf_name)
    @district = getDistrict
    @year =getYear
    @burnableDaysOfWeek = getBurnableDaysOfWeek
    @burnableStartDate = getBurnableStartDay
    @burnableEndDate = getBurnableEndDay
    @petDaysOfWeek = getPETDaysOfWeek
    @petStartDate = getPETStartDay
    @petEndDate = getPETEndDay
    @nonBurnableDates = getNonBurnableDates
    @reusableDates = getReuseDates
  end

  def self.get_pdf_text(pdf_name)
    cmd = "pdftotext -layout #{pdf_name} -"
    text = `#{cmd}`
    #pages = Pdftotext.pages(pdf_name)
    #text = pages[page_number - 1].text
    #puts text
    lines = text.split(/\r?\n/)
    #p lines
    return lines
  end

  def getDistrict
    return @lines[1].split(' ')[1]
  end

  def getYear
    return @lines[0].split(' ')[0].sub(/平成/, '').sub(/年度/, '').to_hankaku.to_i + 1989
  end

  def getBurnableDaysOfWeek
    return @lines[4].split(' ')[1].split('・').map{|s| s.to_wday}
  end

  def getBurnableStartDay
    m, d = getMonthDay(@lines[12])
    return Date.new(getYear + 1, m, d)
  end

  def getBurnableEndDay
    m, d = getMonthDay(@lines[10])
    return Date.new(getYear, m, d)
  end

  def getPETDaysOfWeek
    return @lines[16].split(' ')[1].split('・').map{|s| s.to_wday}
  end
  
  def getPETStartDay
    m, d = getMonthDay(@lines[22])
    return Date.new(getYear + 1, m, d)
  end

  def getPETEndDay
    m, d = getMonthDay(@lines[21])
    return Date.new(getYear, m, d)
  end

  def getMonthDay(line)
    return line.sub(/月/, ' ').sub(/日/, ' ').split(' ').slice(1,2).map{|s| s.to_hankaku.to_i}
  end

  def getNonBurnableDates
    days1 = (@lines[30].split('収集')[0].strip + ' ' + @lines[31].strip).split(' ').map{|s| s.to_hankaku.to_i}
    days2 = @lines[33].split(' ').slice(-12, 12).map{|s| s.to_hankaku.to_i}
    dates = Array.new
    dates.concat(to_dates(days1))
    dates.concat(to_dates(days2))
    return dates
  end

  def getReuseDates
    days1 = @lines[42].split(' ').map{|s| s.to_hankaku.to_i}
    days2 = @lines[45].split(' ').slice(-12,12).map{|s| s.to_hankaku.to_i}
    dates = Array.new
    dates.concat(to_dates(days1))
    dates.concat(to_dates(days2))
    return dates
  end

  def to_dates(days)
    dates = Array.new
    year = getYear
    days.each_with_index do |day, i|
      y = year
      m = i + 4
      if m > 12 then
        m = i + 4 - 12
        y = y +1
      end
      date = Date.new(y, m, day)
      dates.push date
    end
    return dates
  end

  def isRange(date)
    startDate = Date.new(@year,     4, 1)
    endDate   = Date.new(@year + 1, 3, 31)
    return isInRange(date, startDate, endDate)
  end

  def isInRange(date, startDate, endDate)
    if date > endDate then return false end
    if date < startDate then return false end
    return true;
  end

  def isBurnableDay(date)
    if not isRange(date) then return false end
    if isInRange(date, @burnableEndDate, @burnableStartDate) then return false end
    if not @burnableDaysOfWeek.include?(date.wday) then return false end
    return true
  end

  def isPetDay(date)
    if not isRange(date) then return false end
    if isInRange(date, @petEndDate, @petStartDate) then return false end
    if not @petDaysOfWeek.include?(date.wday) then return false end
    return true
  end

  def isNonBurnableDay(date)
    return @nonBurnableDates.include?(date)
  end

  def isReusableDay(date)
    return @reusableDates.include?(date)
  end
end

