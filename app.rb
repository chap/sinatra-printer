require "sinatra"


get '/' do
  puts params
  return params
end

post '/' do
  puts params
  return params
end
