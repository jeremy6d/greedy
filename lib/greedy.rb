$:.unshift(File.join(File.dirname(__FILE__), %w[lib]))

require "rubygems"

require 'gdata'
require 'nokogiri'
require 'json'
require 'cgi'

require 'greedy/connection'
require 'greedy/stream'
require 'greedy/entry'
require 'greedy/feed'

module Greedy
  class ConnectionError < RuntimeError
  end
  
  class AuthorizationError < ConnectionError
    def self.gdata_errors
      %w{AuthorizationError BadRequestError CaptchaError}.collect do |e| 
        "GData::Client::#{e}"
      end
    end
  end
  
  class ServiceError < ConnectionError
    %w{ServerError UnknownError VersionConflictError}.collect do |e| 
      "GData::Client::#{e}"
    end
  end
end