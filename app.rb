require "sinatra"

get '/*' do
  sleep(ENV['SLEEP'].to_i)
#   puts params.to_s
#   puts headers.to_s
#   return params.to_s
  return 'success!'
end


# bump
