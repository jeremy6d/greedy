require 'test_helper'

class TestEntry < Test::Unit::TestCase
  context "A Greedy entry" do
    setup do
      @stream = stub("Greedy::Stream")
      @raw_entry = a_typical_raw_entry_hash
      @feed = stub("Greedy::Feed", :title => "The Feed Title")
      Greedy::Feed.stubs(:new).returns(@feed)
    end
    
    context "initializing" do
      setup do
        @entry = Greedy::Entry.new(@raw_entry, @stream)
      end
      
      should "be able to instantiate from a raw entry hash and a stream" do

        @entry.class.should == Greedy::Entry
      end
    
      should "set href correctly" do
        @entry.href.should == "http://feeds.officer.com/~r/officerrss/top_news_stories/~3/UmVWa_XwtRc/article.jsp"
      end
    
      should "set body correctly" do
        @entry.body.should == "Jeremy Hernandez, 20, was arrested after he tried to pull over an undercover police officer.<img src=\"http://feeds.feedburner.com/~r/officerrss/top_news_stories/~4/UmVWa_XwtRc\" height=\"1\" width=\"1\">"
        @entry.truncated_body.should == "Jeremy Hernandez, 20, was arrested after he tried to pull over an undercover police officer.<img src=\"http://feeds.feedburner.com/~r/officerrss/top_news_stories/~4/UmVWa_XwtRc\" height=\"1\" width=\"1\">"
      end
      
      should "set feed correctly" do
        @entry.feed.should == @feed
      end
    end
    
    should "set truncated_body correctly" do
      @raw_entry['summary']['content'] = File.open("test/fixtures/lorem_ipsum.txt").read
      @entry = Greedy::Entry.new(@raw_entry, @stream)
      @entry.truncated_body.should == "<p>Lorem ipsum putant alterum in ius. Ex partiendo honestatis ius, ex ignota lucilius eam. Nec modo utroque mentitum id, id erant adipisci democritum qui. Veniam altera vim ex. In nullam constituto mei, singulis electram adipiscing eu nam. Eos debet impedit perpetua ad, movet luptatum sit at.  </p>  <p> Ut sale utinam has, at eam enim fabellas probatus. Id sea autem nostro maiorum, ridens cotidieque an eam. Dolore corpora pro cu, eu quodsi probatus deseruisse sea. Eu ullum oratio voluptatum vim.  </p>  <p> Quo labore iisque erroribus ne, homero doctus ex usu. His dicant aliquam verterem in. Eum id zzril altera. Per ei novum perpetua salutandi, noluisse scaevola sententiae an eam.  </p>  <p> Mea no noluisse persequeris, ea eos mazim possit salutandi, aeque malorum eloquentiam usu te. Et vidit nostrum pertinax sea, eros voluptua officiis in vis. Te dolorum molestie inciderint est. Mea ei populo quaeque euripidis, invenire democritum omittantur et mel. Nullam epicurei ex nam, no mea cetero disputationi. Ne utinam feugait sed. No impedit appareat mei, qui at facete aperiam comprehensam, omnes complectitur mea id.  </p>  <p> Eum nostrud laoreet invidunt ne, puto elitr per ex. Modo accusamus ex eos. Sit cu dicam nominati, animal regione eam at. Prima tation suavitate ea eam. Sea error perpetua consetetur ex, duo inani decore dissentias ne. Quidam inimicus vis ad, modo duis et pro, id porro dicunt maluisset eos.  </p>  <p> In elitr ceteros laboramus vis, cu meliore scribentur eum. Ne graece corpora vim, in zzril tamquam persecuti pro. Mel dicit eripuit ad, fugit rationibus consectetuer cu cum. Qui mandamus adipiscing in. Ei duo meis liber, his admodum tincidunt ad. Mea ut detracto iracundia.  </p>  <p> Vel altera labore ponderum an, ea has sapientem gloriatur, ad vim prompta eleifend. Ut per nostro alterum noluisse, in eruditi nostrum vim. No fugit virtute alterum mei, vis ne autem clita. Duo in sonet epicurei expetenda, ea movet erroribus ius, ne usu nihil nobis. Legere liberavisse his ne, pri cibo invenire cotidieque ut. No elaboraret referrentur sit, sea ne iuvaret oporteat. Eum cu quidam maiorum, est ex indoctum rationibus voluptatibus.  </p>"
    end
    
    should "set the title to a default setting if the feed supplies no entry title" do
      @raw_entry['title'] = nil
      Greedy::Entry.new(@raw_entry, @stream).title.should == "The Feed Title - July 22"
    end
    
    should_eventually "be able to share itself" do
      @stream.expects(:change_state_for).with(@entry, "broadcast").returns(true)
      @entry.share!
    end
    
    should_eventually "be able to mark itself read" do
      @stream.expects(:change_state_for).with(@entry, "read").returns(true)
      @entry.mark_as_read!
    end
  end
  
  def a_typical_raw_entry_hash
    { 
      "likingUsers" => [], 
      "comments" => [], 
      "author" => "rss@officer.com (Maggie Ybarra)", 
      "title" => "Fake Texas Cop Tries to Pull Over Undercover Officer", 
      "crawlTimeMsec" => "1279769942562", 
      "published" => 1279773120, 
      "annotations" => [], 
      "alternate" => [ { "href" => "http://feeds.officer.com/~r/officerrss/top_news_stories/~3/UmVWa_XwtRc/article.jsp", 
                         "type" => "text/html"} ], 
      "id" => "tag:google.com,2005:reader/item/1b233c6c984c64b0", 
      "origin" => { "title" => "Officer.com: Top News Stories", 
                    "htmlUrl" => "http://www.officer.com", 
                    "streamId" => "feed/http://feeds.officer.com/officerrss/top_news_stories" }, 
      "summary" => { "content" => "Jeremy Hernandez, 20, was arrested after he tried to pull over an undercover police officer.<img src=\"http://feeds.feedburner.com/~r/officerrss/top_news_stories/~4/UmVWa_XwtRc\" height=\"1\" width=\"1\">", 
                     "direction" => "ltr" }, 
      "categories" => [ "user/17398194162169227368/label/law_enforcement", 
                        "user/17398194162169227368/label/mainstream", 
                        "user/17398194162169227368/label/news", 
                        "user/17398194162169227368/state/com.google/reading-list", 
                        "user/17398194162169227368/state/com.google/fresh", 
                        "Top News Stories" ], 
      "updated" => 1279773120
    }
  end 
end