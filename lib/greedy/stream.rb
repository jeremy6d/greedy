require 'greedy'

module Greedy
  class Stream
    BASE_PATH = "stream/contents/user/-/state/com.google/"    

    attr_accessor :entries    
  
    def initialize(in_connection, in_state = "reading-list", in_options = {})
      @connection = in_connection
      reset!(in_state, in_options)
    end
    
    def reset!(in_state, in_options = {})
      @state = in_state
      @options = in_options
      path = [BASE_PATH, @state].join
      
      pull! @connection.fetch path, @options
    end
    
    def update!(in_state = "reading-list")
      @connection.fetch endpoint(in_state), @options
      
      
      json_hash = parsed_reading_list
      @continuation_token = json_hash['continuation']
      @last_update_token = json_hash['updated']
      @entries = json_hash['items'].collect do |item|
        nil
      end
    end
    
    def retrieve(options)
      # use the continuation to get more info
    end
  
    def parsed_reading_list
      url = Greedy::Connection::BASE_URL + READING_LIST_PATH
      JSON.parse @connection.get(url).body
    end
    
    def set_initial_state! in_state
      @endpoint = 
      retrieve_entries()
    end
    
  protected
    def pull! path, options
      hash = @connection.fetch path, options
      @continuation_token = hash[:continuation]
      @last_update_token = hash[:updated]
    end
  end
end