module Greedy
  class Feed
    attr_reader :google_feed_id, :title, :href, :entries
    
    # Instantiate a record corresponding to a feed
    def initialize(options)
      @title = options['title']
      @href = options['htmlUrl']
      @google_feed_id = options['streamId']
      @entries = options['entries'] || []
    end
  end
end