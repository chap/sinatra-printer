require "sinatra"

get '/*' do
  sleep(20)
  return 'success!'
end


# bump
