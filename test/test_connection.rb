require 'test_helper'

class TestConnection < Test::Unit::TestCase
  context "A Greedy connection" do
    setup do
      @client = stub("gdata client connection")
      @handler = stub("client login handler")
      @handler.stubs(:get_token).with("username", "password", "app").returns("token")
      GData::Client::Base.stubs(:new).with(:auth_handler => @handler).returns(@client)
      GData::Auth::ClientLogin.stubs(:new).with("reader", :account_type => "HOSTED_OR_GOOGLE").returns(@handler)
      @connection = Greedy::Connection.new("username", "password", "app")
    end
    
    context "upon instantiation when authentication succeeds" do
      should "store the Google username" do
        @connection.instance_variable_get("@username").should == "username"
      end
  
      should "store the Google password" do
        @connection.instance_variable_get("@password").should == "password"
      end
      
      should "store the name of the app using this account" do
        @connection.instance_variable_get("@application_name").should == "app"
      end     
      
      should "set the connection object" do
        @connection.instance_variable_get("@client").should == @client
      end
      
      should "correctly respond to connection state inquiry" do
        @connection.should be_connected
      end
    end  
    
    should "fail gracefully when authentication fails" do
      @handler.stubs(:get_token).with("username", "password", "app").raises("a gdata exception")
      conn = Greedy::Connection.new("username", "password", "app")
      conn.should_not be_connected
    end
    
    context "using GData to" do
      setup do
        @body = stub("unparsed response body")
          @response = stub("google reader API response", :body => @body)
        @return_hash = { :eeny => 'meeny', :miney => "moe" }
        JSON.stubs(:parse).with(@body).returns(@return_hash)
      end
      
      context "retrieve data" do
        setup do
          @client.stubs(:get).returns(@response)
        end
      
        should "construct a valid url to the API given a path and options" do
          valid_urls = ["http://www.google.com/reader/api/0/path/to/resource?n=10&t=wesdg",
                        "http://www.google.com/reader/api/0/path/to/resource?t=wesdg&n=10"]
          @client.expects(:get).with do |value|
            valid_urls.include?(value)
          end.returns(@response)
          @connection.fetch("path/to/resource", :n => 10, :t => "wesdg")
        end
      
        should "be able to return the response body parsed into a hash" do
          JSON.expects(:parse).with(@body).returns(@return_hash)
          @connection.fetch("path").should == @return_hash
        end
      end
    
      context "sending data" do
        should "send a POST to the path with the options turned into the POST body" do
          @client.expects(:post).with("http://www.google.com/reader/api/0/sample/path", {:option => 'one'}).returns(@response)
          @connection.post "sample/path", :option => "one"
        end
        should "be able to convert a hash of options into a post body"
        should "be able to handle the response"
      end
    end
  end
end