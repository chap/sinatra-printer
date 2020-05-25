require "sinatra"

get '/*' do
#   sleep(40)
#   puts params.to_s
#   puts headers.to_s
#   return params.to_s
  return 'success!'
end

# bump
