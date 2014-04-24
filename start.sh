. /usr/local/lib/ruby/1.9.3-p125/environment
bundle install
export RACK_ENV=production
nohup ruby app/go_webhook.rb > webhook.log &
