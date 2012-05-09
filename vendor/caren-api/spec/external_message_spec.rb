require 'spec_helper'

describe "ExternalMessage", "converting to xml" do

  before do
    @external_message_a = Caren::ExternalMessage.new( :person_name => "Andre Foeken",
                                                      :external_person_id => 1,
                                                      :body => "Test message",
                                                      :external_id => 1,
                                                      :in_reply_to_id => nil )

    @external_message_b = Caren::ExternalMessage.new( :person_name => "Ria Foeken",
                                                      :external_person_id => 2,
                                                      :body => "Test message reply",
                                                      :external_id => 2,
                                                      :in_reply_to_id => 99 )
  end

  it "should be able to convert a link to valid xml" do
    @external_message_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of links to valid xml" do
    [@external_message_a,@external_message_b].should convert_to_valid_caren_array_xml
  end

end

describe "ExternalMessage", "REST methods" do

  before do
    message = File.read("spec/fixtures/caren_external_message.xml")
    messages = File.read("spec/fixtures/caren_external_messages.xml")

    messages_url = Caren::Api.session.url_for( Caren::ExternalMessage.resource_url(1) )
    message_url = Caren::Api.session.url_for( Caren::ExternalMessage.resource_url(1,1) )
    timestamp = DateTime.now.to_i

    FakeWeb.register_uri(:get, messages_url, :body => messages, :signature => Caren::Api.session.sign(timestamp,nil,messages), :timestamp => timestamp )
    FakeWeb.register_uri(:get, message_url, :body => message, :signature => Caren::Api.session.sign(timestamp,nil,message), :timestamp => timestamp )
    FakeWeb.register_uri(:post, messages_url, :status => 201, :signature => Caren::Api.session.sign(timestamp), :timestamp => timestamp )
    FakeWeb.register_uri(:delete, message_url, :signature => Caren::Api.session.sign(timestamp), :timestamp => timestamp )
  end

  it "should be able to find all external messages" do
    messages = Caren::ExternalMessage.all 1, Caren::Api.session
    messages.should have(2).things
    messages.first.body.should == "Test"
  end

  it "should be able to find one external messages" do
    message = Caren::ExternalMessage.find 1, 1, Caren::Api.session
    message.body.should == "Test"
  end

  it "should be able to create an external message" do
    lambda{ Caren::ExternalMessage.new( :person_name => "Andre Foeken",
                                        :external_person_id => 1,
                                        :body => "Test message",
                                        :external_id => 1,
                                        :subject_id => 1 ).create(Caren::Api.session) }.should_not raise_error
  end

  it "should be able to delete an external message" do
    lambda{ Caren::ExternalMessage.new( :subject_id => 1, :id => 1 ).delete(Caren::Api.session) }.should_not raise_error
  end

end
