require 'gdata'
require 'nokogiri'
require 'json'
require 'ruby-debug'

require 'lib/greedy/connection'
require 'lib/greedy/stream'
require 'lib/greedy/entry'
require 'lib/greedy/feed'

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