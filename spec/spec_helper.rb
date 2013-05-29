require 'rubygems'
require 'spork'

Spork.prefork do
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  $LOAD_PATH.unshift(File.dirname(__FILE__))
  require 'rspec'
  require 'fat_secret'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  RSpec.configure do |config|
    config.fail_fast = false
  end

  module FatSecret
    CONSUMER_KEY = ENV['FS_CONSUMER_KEY']
    SECRET_KEY = ENV['FS_SECRET_KEY']
    ACCESS_TOKEN = ENV['FS_ACCESS_TOKEN']
    ACCESS_SECRET = ENV['FS_ACCESS_SECRET']
  end
end

Spork.each_run do
  load File.dirname(__FILE__) + "/../lib/fat_secret.rb"
end

