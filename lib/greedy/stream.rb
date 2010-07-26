module Greedy
  class Stream
    BASE_PATH = "stream/contents/"
    CHANGE_STATE_PATH = "user/-/state/com.google/edit-tag"  

    attr_accessor :entries, :feeds, :last_update_token
  
    # Instantiate a new Google Reader stream of entries based on a given entry state
    def initialize(username, password, in_state = nil, in_options = {})
      @connection = Greedy::Connection.new(username, password, in_options[:connection_name] || "Greedy::Stream")
      reset!(in_state, in_options)
    end
    
    # Wipe the stream and reinitialize with the given state
    def reset!(in_state = nil, in_options = {})
      @state = in_state || @state || Greedy::Entry::States::READING_LIST
      @options = in_options
      @entries = pull!(endpoint(@state), @options)
      @feeds = distill_feeds_from @entries
    end
    
    # Continue fetching earlier entries from where the last request left off
    def continue!
      return [] unless @continuation_token
      new_entries = pull!(endpoint(@state), @options.merge(:c => @continuation_token))
      @entries.concat new_entries
      new_entries
    end
    
    # Continue fetching later entries from where the last request left off
    def update!
      new_entries = pull!(endpoint(@state), @options.merge(:ot => @last_update_token))
      @entries = new_entries + @entries
      new_entries
    end
    
    def change_state_for(entry, state)
      @connection.post((BASE_PATH + CHANGE_STATE_PATH), { :a => state,
                                                          :i => entry.google_item_id,
                                                          :s => entry.feed.google_feed_id })
    end
    
    def share_all!
      @entries.each { |e| e.share! }
    end
    
    def mark_all_as_read!
      @entries.each { |e| e.mark_as_read! }
    end
    
  protected
    # Retrieve entries based on the provided path and options
    def pull! path, options
      hash = @connection.fetch(path, options) || { 'items' => [] }
      @continuation_token = hash['continuation'] unless options[:ot]
      @last_update_token = hash['updated'] unless options[:c]
      hash["items"].collect do |entry_hash|
        Greedy::Entry.new entry_hash, self
      end
    end
    
    # Accepts an array of entries and sets an array of feeds for the stream
    def distill_feeds_from entry_list
      feeds = entry_list.collect { |e| e.feed }.uniq
      entry_list.each do |e|
        f = feeds.find { |f| f.google_feed_id == e.feed.google_feed_id }
        f.entries.push(e) if f
        f.entries.uniq!
      end
      feeds
    end
    
    # Determine the unique URL segment for a given state
    def endpoint(state)
      File.join BASE_PATH, state
    end
  end
end