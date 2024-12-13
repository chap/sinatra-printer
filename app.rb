ENV['COLOR'] ||= 'white'
require "sinatra"
require "pp"

class Application < Sinatra::Base

  get '/*' do
    return "<html style='font:monospace;background:#{ENV['COLOR']}'><pre>#{ JSON.pretty_generate({params:, headers:request.env.to_h, requestBody:request.body.read.to_s})}</pre></html>"
  end

  post '/*' do
    return "<html style='font:monospace;background:#{ENV['COLOR']}'><pre>#{ JSON.pretty_generate({params:, headers:request.env.to_h, requestBody:request.body.read.to_s})}</pre></html>"
  end

end