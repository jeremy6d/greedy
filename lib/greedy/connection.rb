require 'gdata'
require 'nokogiri'
require 'json'
require 'cgi'

module Greedy
  class Connection
    BASE_URL = "http://www.google.com/reader/api/0/"
    
    # Create a new connection to the Google Reader API
    # Example:
    #   Greedy::Connection.new 'username', 'password', 'my aggregator application'
    def initialize(username, password, appname = "Greedy")
      @username = username
      @password = password
      @application_name = appname
      connect!
    end
    
    # Issue a GET HTTP request to the Google Reader API
    # Example
    #   connection.fetch "stream/contents/user/-/state/com.google/unread", :c => '976H987BKU'
    def fetch(path, options = {})
      url = [full_path(path), convert_to_querystring(options)].join
      response = @client.get url
      JSON.parse response.body
    rescue GData::Client::RequestError => e
      if Greedy::AuthorizationError.gdata_errors.include?(e.class.to_s)
        raise Greedy::AuthorizationError.new(e.message)
      else
        raise Greedy::ServiceError.new(e.message)
      end
    end
    
    # Issue a POST HTTP request to the Google Reader API
    # Example:
    #   connection.fetch "stream/contents/user/-/state/com.google/edit-tag", :form_data => { :async => false, :a => 'broadcast' }
    def post(path, form_data = {})
      uri = [full_path(path), convert_to_querystring(:client => @application_name)].join
      response = @client.post uri, convert_to_post_body(form_data)
      JSON.parse response.body
    rescue GData::Client::RequestError => e
      if Greedy::AuthorizationError.gdata_errors.include?(e.class.to_s)
        raise Greedy::AuthorizationError.new(e.message)
      else
        raise Greedy::ServiceError.new(e.message)
      end
    end
    
    # Determine the status of the connection
    def connected?
      !@client.nil?
    end
    
  protected
    # Perform the connection based on credentials set in intitializer
    # This is all straight from http://code.google.com/apis/gdata/articles/gdata_on_rails.html
    def connect!
      handler = GData::Auth::ClientLogin.new('reader', :account_type => "HOSTED_OR_GOOGLE")
      @token = handler.get_token(@username, @password, @application_name)
      @client = GData::Client::Base.new(:auth_handler => handler)
    rescue GData::Client::RequestError => e
      if Greedy::AuthorizationError.gdata_errors.include?(e.class.to_s)
        raise Greedy::AuthorizationError.new(e.message)
      else
        raise Greedy::ServiceError.new(e.message)
      end
    end
    
    # Build out the full path to a Googler Reader API resource
    def full_path(path)
      File.join(BASE_URL, path)
    end

    # Turn the options hash into a valid querystring for GET requests
    def convert_to_querystring in_hash      
      "?#{parameterize(in_hash)}"
    end
    
    def convert_to_post_body in_hash = {}
      parameterize in_hash.merge(:T => @token, :async => false)
    end
    
    def parameterize in_hash
      result = in_hash.to_a.sort do |a,b|
        a.to_s <=> b.to_s
      end.collect do |key, value|
        [CGI.escape(key.to_s), CGI.escape(value.to_s)].join("=")
      end.join("&")
    end
  end

end