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
    ENV['GO_USER'] = 'user'
    ENV['GO_PWD'] = 'password'
    stub_request(:any, /user:password@.*/)
    post '/notify', {branch_name: "master", project_name: "supporter", commit: { id: "12345" }}.to_json

    host = ENV['GO_HOST'].sub 'http://', ''
    expected_url = "#{ENV['GO_USER']}:#{ENV['GO_PWD']}@#{host}/go/api/pipelines/Supporter/schedule"
    expected_body = "materials[supporter]=12345"

    expect(last_response).to be_ok
    WebMock.should have_requested(:post, expected_url).with { |req| req.body == expected_body }
  end

  it 'should not schedule pipeline if branch is not master' do
    stub_request(:any, /.*/)
    post '/notify', {branch_name: "my_other_branch", project_name: "supporter", commit: { id: "12345" }}.to_json

    expect(last_response).to be_ok
    WebMock.should_not have_requested(:get, /.*/)
  end
end
