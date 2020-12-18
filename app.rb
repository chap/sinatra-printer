require "sinatra"

get '/*' do
  #sleep(40)
  puts params.to_s
  puts headers.to_s
  puts request.inspect
#   return params.to_s
  return 'success!'
end

# bump
