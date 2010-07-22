module Greedy
  class Stream
    BASE_PATH = "stream/contents/user/-/state/com.google/"    

    attr_accessor :entries, :last_update_token
  
    def initialize(username, password, in_state = "reading-list", in_options = {})
      @connection = Greedy::Connection.new(username, password, "Greedy::Stream")
      reset!(in_state, in_options)
    end
    
    def reset!(in_state = "reading-list", in_options = {})
      @state = in_state
      @options = in_options
      @entries = pull!(endpoint(@state), @options)
    end
    
    def continue!
      new_entries = pull!(endpoint(@state), @options.merge(:c => @continuation_token))
      @entries.concat new_entries
      new_entries
    end
    
    def update!
      new_entries = pull!(endpoint(@state), @options.merge(:ot => @last_update_token))
      @entries = new_entries + @entries
      new_entries
    end
    
  protected
    def pull! path, options
      hash = @connection.fetch(path, options) || { 'items' => [] }
      @continuation_token = hash['continuation'] unless options[:ot]
      @last_update_token = hash['updated'] unless options[:c]
      hash["items"].collect do |entry_hash|
        Greedy::Entry.new entry_hash
      end
    end
    
    def endpoint(state)
      File.join BASE_PATH, state
    end
  end
end