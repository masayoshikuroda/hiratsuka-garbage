require_relative 'garbage_pdf.rb'
require_relative 'garbage_cal.rb'

date = Date.today + ARGV[0].to_i
area = ARGV[1]

pdf = GarbagePdf.new(date, area)

cal = GarbageCalendar.new(GarbagePdf::PDF_FILE_NAME)

district = cal.district

message = ''
if cal.isBurnableDay(date) then
  message += '可燃ゴミの日です。'
end
if cal.isPetDay(date) then
  message += 'プラクル・ペットボトルゴミの日です。'
end
if cal.isNonBurnableDay(date) then
  message += '不燃ゴミの日です。'
end
if cal.isReusableDay(date) then
  message += '資源再生物ゴミの日です。'
end
if message.size == 0 then
  message = 'ゴミの収集はありません。'
end

puts '{'
puts '  "district":' + sprintf('"%s"', district) + ','
puts '  "date":    ' + date.strftime('"%Y年%m月%d日"') + ','
puts '  "message": ' + sprintf('"%s"', message)
puts '}'
