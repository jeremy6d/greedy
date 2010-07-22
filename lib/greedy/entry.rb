module Greedy  
  class Entry
    attr_reader :title, :author, :href, :google_item_id, :feed, :categories, :body
  
    def initialize(item)
      raise "Title is nil" unless item['title']
      @title = normalize item['title']
      @author = normalize item['author'] 
      @href = item['alternate'].first['href']
      @google_item_id = item['id']
      @published = item['published']
      @updated = item['updated']
      @body = normalize get_body(item)
      @feed = Greedy::Feed.new(item['origin'])
    end
  
    def sort_by_time
      updated_at || published_at
    end
  
    def published_at
      Time.at @published rescue nil
    end
  
    def updated_at
      Time.at @updated rescue nil
    end
  
    def body=(text)
      # parse body text into tag collections
      # isolate paragraphs, blockquotes, and images
      # grab first three paragraphs
      # take word count of these paragraphs, find cutoff point
      # close tags and return
    end
  
  protected

    def get_body(item_hash)
      container = item_hash['content'] || item_hash['summary'] || item_hash['description']
      return container['content']
    rescue
      nil
    end
  
    def normalize(text)
      return text if text.nil?
      Nokogiri::XML::DocumentFragment.parse(text).to_html
    end
  end
end