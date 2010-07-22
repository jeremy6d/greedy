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
      url = [full_path(path), convert_to_querystring(options)].join
      response = @client.get url
      JSON.parse response.body
    end
    
    def post(path, form_data = {})
      response = @client.post full_path(path), :form_data => form_data.merge(:T => @token, :async => false)
      JSON.parse response.body
    end
    
    def connected?
      !@client.nil?
    end
    
  protected
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