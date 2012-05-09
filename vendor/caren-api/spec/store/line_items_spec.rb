require 'spec_helper'

describe "Store::LineItem", "converting to xml" do

  before do
    @line_item_a = Caren::Store::LineItem.new( :price_in_cents => 1900 )
    @line_item_b = Caren::Store::LineItem.new( :price_in_cents => 1499 )
  end

  it "should be able to convert a line item to valid xml" do
    @line_item_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of line items to valid xml" do
    [@line_item_a,@line_item_b].should convert_to_valid_caren_array_xml
  end

end

describe "LineItem", "REST methods" do

  before do
    line_item_url = Caren::Api.session.url_for( Caren::Store::LineItem.resource_url(1) )
    timestamp = DateTime.now.to_i
    FakeWeb.register_uri(:delete, line_item_url, :body => nil, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,nil) )
  end

  it "should be able to delete a specific line item" do
    lambda{ Caren::Store::LineItem.new(:id=>1).delete Caren::Api.session }.should_not raise_error
  end

end
