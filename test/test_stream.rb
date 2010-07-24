require 'test_helper'

class TestStream < Test::Unit::TestCase
  context "A Greedy stream" do
    setup do
      @connection = stub("a greedy connection", :fetch => {} )
    end
  
    context "initializing with successful pull from Google" do
      setup do
        @response_hash = eval(File.open('test/fixtures/success_json_hash.txt').read)
        @connection.expects(:fetch).with("stream/contents/user/-/state/com.google/reading-list", {}).returns(@response_hash)
        Greedy::Connection.expects(:new).with("username", "passwort", "Greedy::Stream").returns(@connection)
        @reading_list = Greedy::Stream.new "username", "passwort"
      end
  
      should "set the continuation token" do
        @reading_list.instance_variable_get("@continuation_token").should == "continuationtoken"
      end
  
      should "set the last update token" do
        @reading_list.last_update_token.should == 1234567890
      end
  
      should "set the entries" do
        @reading_list.entries.size.should == 5
      end
      
      context "when continuing" do
        setup do
          assert_equal @reading_list.instance_variable_get("@continuation_token"), "continuationtoken"
          @continued_response_hash = eval(File.open('test/fixtures/another_success_hash.txt').read)
          @connection.expects(:fetch).with("stream/contents/user/-/state/com.google/reading-list", 
                                             { :c => "continuationtoken" }).returns(@continued_response_hash)
        end
        
        should "send the continuation token on the next pull" do
          @reading_list.continue!
          @reading_list.instance_variable_get("@continuation_token").should == "CKXmmOLq_aIC"
        end
        
        should "increase the entries size" do
          entry_count = @reading_list.entries.size
          continued_count = @reading_list.continue!.size
          @reading_list.entries.size.should == (entry_count + continued_count)
        end
        
        should "not change the last update token" do
          token = @reading_list.instance_variable_get("@last_update_token")
          @reading_list.continue!
          @reading_list.instance_variable_get("@last_update_token").should == token
        end
      end
      
      context "when resetting" do
        setup do
          @connection.expects(:fetch).with("stream/contents/user/-/state/com.google/reading-list", {}).returns(@response_hash)
          @reading_list.reset!
        end
        
        should "reset the entries" do
          @reading_list.entries.size.should == 5
        end
        
        should "set the last update token" do
          @reading_list.last_update_token.should == 1234567890
        end

        should "set the continuation token" do
          @reading_list.instance_variable_get("@continuation_token").should == "continuationtoken"
        end
      end
      
      context "when updating" do
        setup do
          @updated_hash = eval(File.open('test/fixtures/update_hash.txt').read)
          @connection.expects(:fetch).with("stream/contents/user/-/state/com.google/reading-list", 
                                           { :ot => 1234567890 }).returns(@updated_hash)
          @reading_list.update!
        end
        
        should "append new entries" do
          @reading_list.entries.size.should == 6
        end
        
        should "set the last update token" do
          @reading_list.last_update_token.should == 1279769942
        end
        
        should "not set the continuation token" do
          @reading_list.instance_variable_get("@continuation_token").should_not == "CKDIsM2M_qIC"
        end
      end
      
      context "when changing the state of an entry" do
        setup do
          @connection.expects(:post).with("broadcast", { :a => state,
                                                         :i => entry.google_item_id,
                                                         :s => entry.feed.google_feed_id })
        end
      end
    end
    
    context "intializing with bad credentials" do
      setup do
        Greedy::Connection.stubs(:new).with("username", "passwort", "Greedy::Stream").raises(Greedy::AuthorizationError)
      end
      
      should "raise error on initialization" do
        lambda { Greedy::Stream.new "username", "passwort" }.should raise_error(Greedy::AuthorizationError)
      end
    end
  end
end