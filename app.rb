ENV['COLOR'] ||= 'white'
require "sinatra"
require "pp"

class Application < Sinatra::Base

  get '/*' do
    payload = JSON.pretty_generate({params:, requestBody:request.body.read.to_s})
    puts payload
    return "<html style='font:monospace;background:#{ENV['COLOR']}'><pre>#{payload}</pre></html>"
  end

  post '/*' do
    payload = JSON.pretty_generate({params:, requestBody:request.body.read.to_s})
    puts payload
    return "<html style='font:monospace;background:#{ENV['COLOR']}'><pre>#{payload}</pre></html>"
  end

end