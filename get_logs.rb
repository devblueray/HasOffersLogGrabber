require 'open-uri'
require 'trollop'
require 'json'
require 'httparty'
require 'zip'

token = "Token"
id = "id"
tmpdir ='c:\Temp'

def getLogFileNames(date,type,token, id)

    logFileName = open("https://api.hasoffers.com/Apiv3/json?NetworkId=#{id}&Target=RawLog&Method=listLogs&NetworkToken=#{token}&log_type=#{type}&date_dir=#{date}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    response = JSON.parse(logFileName.read, symbolize_names: true)
    arrFileNames = response[:response][:data][:logFiles]
  end

def getDownloadUrl(filename, type, token, id)
  downloadLink = open("https://api.hasoffers.com/Apiv3/json?NetworkId=#{id}&Target=RawLog&Method=getDownloadLink&NetworkToken=#{token}&log_type=#{type}&log_filename=#{filename}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
  response = JSON.parse(downloadLink.read, symbolize_names: true)
  return response[:response][:data][:link]
end

def downloadFiles(filename,tempdir)
  rnd = Random.new.rand(10000000)
  fname = "#{tempdir}/#{rnd}.zip"

  File.open(fname, 'wb') do |f|
    f.write HTTParty.get(filename, :verify => false)

    Zip::File.open(fname) do |zip_file|
      zip_file.each { |entry| entry.extract("#{tempdir}/#{rnd}.txt") }
    end
    f = File.open("#{tempdir}/#{rnd}.txt", 'r')
    log = File.open("#{tempdir}/final/log.txt", 'a+')
    f.each_with_index do |line, index, |
      next if index == 0
      log.write(line)
    end
  end

end

opts = Trollop::options do
  opt :date, 'Dates you want to get logs for', :multi => true, :type => :string
  opt :type, 'Type of logs you want (click, conversion)', :type => :string
end

opts[:date].each do |d|
  filenames = getLogFileNames(d,opts[:type], token, id)
  filenames.each do |f|
  downloadFiles(getDownloadUrl(f[:filename], opts[:type], token, id), tmpdir)
  end
end





