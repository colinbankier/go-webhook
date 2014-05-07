require "sinatra"
require 'json'
require 'net/http'
require 'dotenv'

Dotenv.load

post '/notify' do
  logger.info "Got request with data: #{data}"
  if data['branch_name'] == 'master' && data['project_name'] == 'supporter'
    trigger_pipeline "Supporter_Master_Build", "materials[#{data['project_name']}]=#{data['commit']['id']}&variables[STATUS]=#{data["result"]}"
  elsif successful_master(data) && data['project_name'] == 'command_centre'
    trigger_pipeline "Heroix_Staging_1", "variables[COMMIT]=#{data['commit']['id']}"
  elsif successful_master(data) && data['project_name'] == 'payments'
    trigger_pipeline "payments_production", "materials[#{data['project_name']}]=#{data['commit']['id']}"
  else
    logger.info "Skipping non master branch or failed build - #{data['project_name']}"
    "Not master branch"
  end
end

def successful_master data
  data['branch_name'] == 'master' && data["result"] == "passed"
end

def trigger_pipeline name, body
  uri = URI("#{ENV['GO_HOST']}/go/api/pipelines/#{name}/schedule")
  req = build_request uri, body
  do_request uri, req
end

def build_request uri, body
    req = Net::HTTP::Post.new(uri.path)
    req.body = body
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
