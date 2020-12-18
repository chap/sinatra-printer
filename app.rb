require "sinatra"

get '/*' do
  #sleep(40)
  puts params.to_s
  puts headers.to_s
  puts request.body
  return 'success!'
end

post '/*' do
  #sleep(40)
  puts params.to_s
  puts headers.to_s
  puts request.body
  return 'success!'
end

# bump
