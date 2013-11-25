require "sinatra"
require 'json'
require 'net/http'
require 'dotenv'

Dotenv.load

post '/notify' do
  if data['branch_name'] == 'master'
    uri = URI("#{ENV['GO_HOST']}/go/api/pipelines/Supporter/schedule")
    req = build_request uri
    do_request uri, req
  else
    "Not master branch"
  end
end

def build_request uri
    req = Net::HTTP::Post.new(uri.path)
    req.body = "materials[#{data['project_name']}]=#{data['commit']['id']}"
    req.basic_auth ENV['GO_USER'], ENV['GO_PWD']
    req
end

def data
  request.body.rewind  # in case someone already read it
  JSON.parse request.body.read
end

def do_request uri, req
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      puts uri.to_s
      puts req.body
      http.request(req)
    end

    handle_response res
end

def handle_response res
    puts res.value
    puts res.body
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      res.body
    else
      res.value
    end
end
