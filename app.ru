# Run using "rackup -p 4567 app.ru"

require 'rubygems'
require 'sinatra'
require 'twilio'
require 'thread'
require 'pp'

CallerID = "+13233029253" 

Twilio.connect "AC3ef7e0ae57a87f5fb649f37a0f5e5d18", "6b3ab9255da1ac23a2c96d2c54e48ed9"

Thread.abort_on_exception = true

log = "call.log"

class Callbox < Sinatra::Base
  get '/' do
    "<pre>#{File.read(log)}</pre>"
  end

  post '/call' do
    <<-XML
<?xml version="1.0" encoding="UTF-8" ?>  
<Response>
    <Say>Enter Code</Say>
    <Gather action="/code" method="POST" numDigits="4" timeout="20"/>
</Response>
    XML
  end

  post "/code" do
    code = params["Digits"]

    if File.read("code").strip == code
      File.open(log, "a") do |f|
        f.puts "#{Time.now}: ok"
      end

      <<-XML
<?xml version="1.0" encoding="UTF-8" ?>  
<Response> 
  <Play>http://elle.fallingsnow.net/callbox/9999.wav</Play>
</Response>
      XML
    else
      File.open(log, "a") do |f|
        f.puts "#{Time.now}: fail"
      end

      <<-XML
<?xml version="1.0" encoding="UTF-8" ?>  
<Response>
  <Say>Wrong code</Say>
</Response>
      XML
    end
  end
end

run Callbox
