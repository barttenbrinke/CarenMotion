require 'spec_helper'

describe "Billable", "converting to xml" do

  before do
    @billable_a = Caren::Store::Billable.new( :name => "Washing", :price => 100.euros, :in_store => true, :type => "Product" )
    @billable_b = Caren::Store::Billable.new( :name => "Bedpan", :price => 100.euros, :in_store => false, :type => "Product" )
  end

  it "should be able to convert a billable to valid xml" do
    @billable_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of billables to valid xml" do
    [@billable_a,@billable_b].should convert_to_valid_caren_array_xml
  end

end

describe "Billable", "REST methods" do

  before do
    billable = File.read("spec/fixtures/caren_billable.xml")
    billables = File.read("spec/fixtures/caren_billables.xml")
    billable_search = File.read("spec/fixtures/caren_billables_search.xml")

    billable_url = Caren::Api.session.url_for( Caren::Store::Billable.resource_url(1) )
    billables_url = Caren::Api.session.url_for( Caren::Store::Billable.resource_url )
    search_url = Caren::Api.session.url_for( "#{Caren::Store::Billable.resource_url}?key=name&value=bedpan" )

    timestamp = DateTime.now.to_i

    FakeWeb.register_uri(:post, billables_url, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp) )
    FakeWeb.register_uri(:put, billable_url, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp) )
    FakeWeb.register_uri(:get, billables_url, :body => billables, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,billables) )
    FakeWeb.register_uri(:get, billable_url, :body => billable, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,billable) )
    FakeWeb.register_uri(:delete, billable_url, :body => nil, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,nil) )
    FakeWeb.register_uri(:get, search_url, :body => billable_search, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,billable_search) )
  end

  it "should be able to update a billable" do
    lambda{ Caren::Store::Billable.new( :id => 1, :name => "Bedpan" ).update( Caren::Api.session ) }.should_not raise_error
  end

  it "should be able to update the photo for a product" do
    lambda{ Caren::Store::Billable.new( :id => 1 ).update_photo( "spec/fixtures/bacon.jpg", Caren::Api.session ) }.should_not raise_error
  end

  it "should be able to find a specific billable" do
    billable = Caren::Store::Billable.find 1, Caren::Api.session
    billable.name.should == "Dishwashing"
  end
  
  it "should be able to delete a specific billable" do
    lambda{ Caren::Store::Billable.new( :id => 1 ).delete(Caren::Api.session) }.should_not raise_error
  end

  it "should be able to search for a specific product" do
    billables = Caren::Store::Billable.search :name, "bedpan", Caren::Api.session
    billables.should have(1).things
    billables.first.name.should == "bedpan"
  end

  it "should be able to find all billables" do
    billables = Caren::Store::Billable.all Caren::Api.session
    billables.should have(2).things
    billables.first.name.should == "Dishwashing"
  end

end
