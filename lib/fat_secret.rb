require 'net/http'
require 'json'
require 'openssl'
require 'cgi'
require 'base64'

require 'mharris_ext'
require 'andand'
require 'redis'

module FatSecret
  def self.load_files!
    %w(remote_method ext api cache request http_api).each do |f|
      load File.expand_path(File.dirname(__FILE__) + "/fat_secret/#{f}.rb")
    end
  end
end

FatSecret.load_files!