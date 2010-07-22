module Greedy
  class Feed
    attr_reader :google_feed_id, :title, :href

    def initialize(options)
      @title = options['title']
      @href = options['htmlUrl']
      @google_feed_id = options['streamId']
    end
  end
end