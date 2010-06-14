module Greedy
  class Connection
    BASE_URL = "http://www.google.com/reader/api/0/"
    
    def initialize(username, password, appname = "Greedy")
      @username = username
      @password = password
      @application_name = appname
      connect!
    end
    
    
    def fetch(path, options = {})
      response = @client.get [full_path(path), convert_to_querystring(options)].join
      JSON.parse response.body
    end
    
    def post(path, options = {})
      response = @client.post full_path(path), options
      JSON.parse response.body
    end
    
    def connected?
      !@client.nil?
    end
    
  protected
    # This is all straight from http://code.google.com/apis/gdata/articles/gdata_on_rails.html
    def connect!
      handler = GData::Auth::ClientLogin.new('reader', :account_type => "HOSTED_OR_GOOGLE")
      token = handler.get_token(@username, @password, @application_name)
      @client = GData::Client::Base.new(:auth_handler => handler)
      connected?
    rescue Exception => e
      (@client = nil) && true
    end
    
    def full_path(path)
      File.join(BASE_URL, path)
    end

    def convert_to_querystring in_hash
      result = in_hash.collect do |key, value|
        [key.to_s, value.to_s].join("=")
      end.join("&")
      "?#{result}"
    end
  end
end