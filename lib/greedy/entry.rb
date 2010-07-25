module Greedy  
  class Entry
    attr_reader :title, :author, :href, :google_item_id, :feed,
                :categories, :body, :truncated_body, :stream

    module States
      ALL = ["read",                    # A read item will have the state read
             "kept-unread",             # Once you've clicked on "keep unread", an item will have the state kept-unread
             "fresh",                   # When a new item of one of your feeds arrive, it's labeled as fresh. When (need to find what remove fresh label), the fresh label disappear.
             "broadcast",               # When your mark an item as being public, you set it's broadcast state
             "reading-list",            # All you items are flagged with the reading-list state. To see all your items, just ask for items in the state reading-list
             "tracking-body-link-used", # Set if you ever clicked on a link in the description of the item.
             "tracking-emailed",        # Set if you ever emailed the item to someone.
             "tracking-item-link-used", # Set if you ever clicked on a link in the description of the item.
             "tracking-kept-unread"     # Set if you ever mark your read item as unread.
            ]
      ALL.each do |name|
        const_set name.upcase.gsub("-", "_"), "user/-/state/com.google/#{name}"
      end
    end
    
    DEFAULT_CHAR_COUNT = 2000
  
    # Instantiate and normalize a new Google Reader entry
    def initialize(item, stream = nil)
      @stream = stream
      @feed = Greedy::Feed.new(item['origin'])
      
      @author = normalize item['author']  
      @google_item_id = item['id']
      @published = item['published']
      @updated = item['updated']
      
      set_body!(item)
      set_title!(item)
      set_href!(item)
    end
  
    # Provide the entry time by which the entry should be sorted amongst other entries
    def sort_by_time
      (updated_at || published_at)
    end
  
    # Provide the canonical publish date in +Time+ format
    def published_at
      Time.at @published rescue nil
    end
  
    # Provide the canonical date and time of update in +Time+ format
    def updated_at
      Time.at @updated rescue nil
    end
    
    def mark_as_read!
      stream.change_state_for(self, States::READ)
    end
    
    def share!
      stream.change_state_for(self, States::BROADCAST)
    end
  
  protected
    def set_href!(hash)
      links = hash['alternate']
      @href = (links.first['href'] unless (links.nil? || links.empty?)) || @feed.href
    end
  
    def set_title!(hash)
      raw_title = hash['title'] || "#{@feed.title} - #{published_at.strftime "%B %d"}"
      @title = normalize raw_title
      true
    end
    
    def normalize(text)
      return text if text.nil?
      Nokogiri::XML::DocumentFragment.parse(text).to_html
    end
    
    def set_body!(in_hash)
      raw_text = begin
        key = %w(content summary container).detect { |key| in_hash[key] }
        in_hash[key]['content']
      rescue
        return false  
      end
      
      @body = normalize raw_text
      
      doc = Nokogiri::XML::DocumentFragment.parse(@body)
      count = index = 0
      truncated = false

      doc.children.each do |child|
        count = count + child.content.length.to_i
        index = index + 1
        if count > DEFAULT_CHAR_COUNT
          truncated = true
          break
        end
      end

      @truncated_body = doc.children.slice(0, index).to_html
      true
    end
  end
end