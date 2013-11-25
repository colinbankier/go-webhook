path = File.join(File.dirname(__FILE__), '../app')
$:.unshift path

require 'webmock/rspec'
require 'dotenv'

Dotenv.load
