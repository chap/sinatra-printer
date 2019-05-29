require "sinatra"

get '/*' do
  puts params.to_s
  puts headers.to_s
  return params.to_s
end

#bump
