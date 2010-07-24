require 'nokogiri'

module Greedy  
  class Entry
    attr_reader :title, :author, :href, :google_item_id, :feed,
                :categories, :body, :truncated_body, :stream
    
    # Entry States
    # read   A read item will have the state read
    # kept-unread  Once you've clicked on "keep unread", an item will have the state kept-unread
    # fresh  When a new item of one of your feeds arrive, it's labeled as fresh. When (need to find what remove fresh label), the fresh label disappear.
    # starred  When your mark an item with a star, you set it's starred state
    # broadcast  When your mark an item as being public, you set it's broadcast state
    # reading-list   All you items are flagged with the reading-list state. To see all your items, just ask for items in the state reading-list
    # tracking-body-link-used  Set if you ever clicked on a link in the description of the item.
    # tracking-emailed   Set if you ever emailed the item to someone.
    # tracking-item-link-used  Set if you ever clicked on a link in the description of the item.
    # tracking-kept-unread   Set if you ever mark your read item as unread.
    module States
      ALL = ["read", "kept-unread", "fresh", "starred", "broadcast", 
             "reading-list", "tracking-body-link-used", "tracking-emailed",
             "tracking-item-link-used", "tracking-kept-unread"]
      ALL.each do |name|
        const_set name.upcase.gsub("-", "_"), "user/-/state/com.google/#{name}"
      end
    end
    
    DEFAULT_CHAR_COUNT = 2000
  
    # Instantiate and normalize a new Google Reader entry
    def initialize(item, stream)
      @stream = stream
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
  
    # Provide the entry time by which the entry should be sorted amongst other entries
    def sort_by_time
      updated_at || published_at
    end
  
    # Provide the canonical publish date in +Time+ format
    def published_at
      Time.at @published rescue nil
    end
  
    # Provide the canonical date and time of update in +Time+ format
    def updated_at
      Time.at @updated rescue nil
    end
  
    # Set the body of the entry as normalized text and create a truncated version
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
    
    def mark_as_read!
      stream.change_state_for(self, States::READ)
    end
    
    def share!
      stream.change_state_for(self, States::BROADCAST)
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