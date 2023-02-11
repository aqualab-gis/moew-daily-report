require 'date'

PREFIX = "https://www.moew.government.bg/static/media/ups/tiny/Daily%20Bulletin/"

(Date.new(2020,5,4)..Date.today).map { "#{_1.strftime("%d%m%Y")}_Bulletin_Daily.pdf" }.each do |file|
  next if File.exist?(File.join('reports', file))
  puts PREFIX + file
end
