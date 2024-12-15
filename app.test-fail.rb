require 'minitest/autorun'
require 'rack/test'
require_relative 'app' # Replace 'app' with the name of your Sinatra file if different

class ApplicationTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Application
  end

  def setup
    @default_color = 'white'
    @test_color = 'blue'
  end

  def test_get_request_with_default_color_fail
    ENV['COLOR'] = @default_color
    get '/test?foo=bar'
    
    assert last_response.ok?
    assert_match "background:clear", last_response.body
    assert_match '"foo": "bar"', last_response.body
  end

  def test_post_request_with_custom_color
    ENV['COLOR'] = @test_color
    post '/test', { key: 'value' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    
    assert last_response.ok?
    assert_match "background:#{@test_color}", last_response.body
    assert_match '"requestBody": "{\\"key\\":\\"value\\"}"', last_response.body
  end
end
