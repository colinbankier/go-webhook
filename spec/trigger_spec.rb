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

  it 'schedules go pipeline' do
    puts "Go Host: #{ENV['GO_HOST']}"
    stub_request(:any, /user:password@.*/)
    post '/notify', {branch_name: "master", project_name: "supporter", commit: { id: "12345" }}.to_json

    host = ENV['GO_HOST'].sub 'http://', ''
    expected_url = "#{ENV['GO_USER']}:#{ENV['GO_PWD']}@#{host}/go/api/pipelines/Supporter/schedule"
    expected_body = "materials[supporter]=12345"

    puts last_response
    expect(last_response).to be_ok
    WebMock.should have_requested(:post, expected_url).with { |req| req.body == expected_body }
  end
end
