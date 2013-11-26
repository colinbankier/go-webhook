require "sinatra"
require 'json'
require 'net/http'
require 'dotenv'

Dotenv.load

post '/notify' do
  logger.info "Got request with data: #{data}"
  if data['branch_name'] == 'master'
    uri = URI("#{ENV['GO_HOST']}/go/api/pipelines/Supporter/schedule")
    req = build_request uri
    do_request uri, req
  else
    logger.info "Skipping non master branch"
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
  logger.info "Triggering #{uri} with #{req.body}"
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
      logger.info "Trigger Ok: #{res.body}"
      res.body
    else
      logger.info "Trigger error: #{res.value}"
      logger.info "Trigger error: #{res.body}"
      res.value
    end
end
