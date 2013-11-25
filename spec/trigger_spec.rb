ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'go_webhook'
require 'sinatra'
require 'rspec'
require 'rack/test'

describe 'The GO Webhook App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'says hello' do
    get '/'
    expect(last_response).to be_ok
  end
end
