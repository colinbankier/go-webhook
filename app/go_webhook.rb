require "sinatra"
require 'json'
require 'net/http'
require 'dotenv'

Dotenv.load

post '/notify' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read

  uri = URI("#{ENV['GO_HOST']}/go/api/pipelines/Supporter/schedule")
  req = Net::HTTP::Post.new(uri.path)
  req.body = "materials[#{data['project_name']}]=#{data['commit']['id']}"
  req.basic_auth ENV['GO_USER'], ENV['GO_PWD']
  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    puts uri.to_s
    puts req.body
    http.request(req)
  end

  puts res.value
  puts res.body
  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    res.body
  else
    res.value
  end
end

get "/" do
  request.inspect
end
