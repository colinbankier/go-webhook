bundle install
export RACK_ENV=production
nohup ruby app/go_webhook.rb > webhook.log &
