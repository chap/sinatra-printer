require "sinatra"

get '/*' do
  #sleep(40)
  puts params.to_s
  puts headers.to_s
  puts request.body.read.to_s
  return 'success!'
end

post '/*' do
  #sleep(40)
  puts params.to_s
  puts headers.to_s
  puts request.inspect
  return 'success!'
end

# bump
