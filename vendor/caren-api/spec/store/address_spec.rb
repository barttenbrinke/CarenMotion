require 'spec_helper'

describe "Store::Address", "converting to xml" do

  before do
    @address_a = Caren::Store::Address.new( :full_name => "Andre Foeken" )
    @address_b = Caren::Store::Address.new( :full_name => "Bart ten Brinke" )
  end

  it "should be able to convert an address to valid xml" do
    @address_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of addresses to valid xml" do
    [@address_a,@address_b].should convert_to_valid_caren_array_xml
  end

end