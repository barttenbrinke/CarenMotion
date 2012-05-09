require 'spec_helper'

describe "BillableCategory", "converting to xml" do

  before do
    @billable_category_a = Caren::Store::BillableCategory.new( :name => "Services" )
    @billable_category_b = Caren::Store::BillableCategory.new( :name => "Products" )
  end

  it "should be able to convert a product to valid xml" do
    @billable_category_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of products to valid xml" do
    [@billable_category_a,@billable_category_b].should convert_to_valid_caren_array_xml
  end

end

describe "BillableCategory", "REST methods" do

  before do
    billable_category = File.read("spec/fixtures/caren_billable_category.xml")
    billable_categories = File.read("spec/fixtures/caren_billable_categories.xml")
    billable_categories_search = File.read("spec/fixtures/caren_billable_categories_search.xml")

    billable_category_url = Caren::Api.session.url_for( Caren::Store::BillableCategory.resource_url(1) )
    billable_categories_url = Caren::Api.session.url_for( Caren::Store::BillableCategory.resource_url )
    search_url = Caren::Api.session.url_for( "#{Caren::Store::BillableCategory.resource_url}?key=name&value=billables" )

    timestamp = DateTime.now.to_i

    FakeWeb.register_uri(:get, billable_categories_url, :body => billable_categories, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,billable_categories) )
    FakeWeb.register_uri(:get, billable_category_url, :body => billable_category, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,billable_category) )
    FakeWeb.register_uri(:get, search_url, :body => billable_categories_search, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,billable_categories_search) )
  end

  it "should be able to search for a specific billable category" do
    billable_categories = Caren::Store::BillableCategory.search :name, "billables", Caren::Api.session
    billable_categories.should have(1).things
    billable_categories.first.name.should == "Billables"
  end

  it "should be able to find a billable category" do
    billable_category = Caren::Store::BillableCategory.find 1, Caren::Api.session
    billable_category.name.should == "Billables"
  end

  it "should be able to find all billable category" do
    billable_categories = Caren::Store::BillableCategory.all Caren::Api.session
    billable_categories.should have(2).things
    billable_categories.first.name.should == "Products"
  end

end
