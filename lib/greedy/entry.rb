require 'nokogiri'

module Greedy  
  class Entry
    attr_reader :title, :author, :href, :google_item_id, :feed, :categories, :body, :truncated_body
    
    DEFAULT_CHAR_COUNT = 2000
  
    def initialize(item)
      raise "Title is nil" unless item['title']
      @title = normalize item['title']
      @author = normalize item['author'] 
      @href = item['alternate'].first['href']
      @google_item_id = item['id']
      @published = item['published']
      @updated = item['updated']
      body = get_body(item)
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
  
    def body=(text, char_count = DEFAULT_CHAR_COUNT)
      @body = normalize(text)
      doc = Nokogiri::XML::DocumentFragment.parse(@body)
      count = index = 0
      truncated = false

      doc.children.each do |child|
        count = count + child.content.length.to_i
        index = index + 1
        if count > char_count
          truncated = true
          break
        end
      end

      @truncated_body = doc.children.slice(0, index).to_html
      @body
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