require 'spec_helper'

describe "EventSlotContainer", "converting to xml" do

  before do
    @employee = Caren::Employee.new( :first_name => "Andre", :last_name => "Foeken", :external_id => 3, :bio => "")
    @slot_a = Caren::EventSlot.new( :date => Date.today, :start => "10:00", :duration => 3600)
    @slot_b = Caren::EventSlot.new( :date => Date.today + 1, :start => "10:00", :duration => 7200)
    @event_slot_container = Caren::EventSlotContainer.new( :employee => @employee, :event_slots => [@slot_a,@slot_b])
  end

  it "should be able to convert an event to valid xml" do
     hash = Hash.from_xml @event_slot_container.to_xml
     hash["event_slot_container"]["event_slots"].should have(2).things
     hash["event_slot_container"]["event_slots"].first["start"].should == "10:00"
     hash["event_slot_container"]["employee"]["first_name"].should == "Andre"
  end

  it "should be able to convert an array of events to valid xml" do
    hash = Hash.from_xml Caren::EventSlotContainer.to_xml([@event_slot_container])
    hash["event_slot_containers"].first["event_slots"].should have(2).things
    hash["event_slot_containers"].first["event_slots"].first["start"].should == "10:00"
    hash["event_slot_containers"].first["employee"]["first_name"].should == "Andre"    
  end

end
