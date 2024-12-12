ENV['COLOR'] ||= 'blue'
require "sinatra"
require "pp"

get '/*' do
  #sleep(40)
  puts params.to_s
  puts headers.to_s
  puts request.body.read.to_s
  return "<html style='font:monospace;background:#{ENV['COLOR']}'><pre>#{ JSON.pretty_generate({params:, headers:headers.to_h, requestBody:request.body})}</pre></html>"
end

post '/*' do
  #sleep(40)
  puts params.to_s
  puts headers.to_s
  puts request.inspect
  puts 'body!'
  puts request.body.read
  return 'success!'
end

# bump
