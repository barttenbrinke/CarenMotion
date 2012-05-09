require 'spec_helper'

describe "EventSlot", "converting to xml" do

  before do
    @slot_a = Caren::EventSlot.new( :date => Date.today, :start => "10:00", :duration => 3600)
    @slot_b = Caren::EventSlot.new( :date => Date.today + 1, :start => "10:00", :duration => 7200)
  end

  it "should be able to convert an event to valid xml" do
    @slot_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of events to valid xml" do
    [@slot_a,@slot_b].should convert_to_valid_caren_array_xml
  end

end
