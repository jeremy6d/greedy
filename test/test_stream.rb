# require 'test_helper'
# 
# class TestStream < Test::Unit::TestCase
# #   context "A Greedy stream" do
# #         setup do
# #           @connection = stub("a greedy stream of news")
# #         end
# #       
# #         context "updating from Google" do
# #           setup do
# #             
# #           end
# #       
# #           context "successfully" do
# #             setup do
# #               @response_hash = eval(File.open('test/fixtures/success.txt').read)
# #               JSON.stubs(:parse).with(@body).returns(@response_hash)
# #               @reading_list.update!
# #             end
# #         
# #             should "set the continuation token" do
# #               @reading_list.instance_variable_get("@continuation_token").should == "continuationtoken"
# #             end
# #         
# #             should "set the last update token" do
# #               @reading_list.instance_variable_get("@last_update_token").should == 1234567890
# #             end
# #         
# #             should "set the entries" do
# #               @reading_list.entries.size.should == 5
# #             end
# #           end
# #         end
# end