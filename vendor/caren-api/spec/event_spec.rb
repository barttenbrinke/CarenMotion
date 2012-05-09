require 'spec_helper'

describe "Event", "converting to xml" do

  before do
    @event_a = Caren::Event.new( :external_id => 1, :name => "Washing", :comment => "Real good", :start => "12:00",
                                 :duration => 30, :valid_from => Date.today, :valid_to => Date.today+1.day,
                                 :person_first_name => "Andre", :person_last_name => "Foeken", :person_male => true, :external_person_id => 100 )

    @event_b = Caren::Event.new( :external_id => 2, :name => "Clothing", :comment => "Real bad",
                                 :start => "13:00", :duration => 30, :valid_from => Date.today, :valid_to => Date.today+1.day,
                                 :person_first_name => "Oscar", :person_last_name => "Foeken", :person_male => true, :external_person_id => 101 )
  end

  it "should be able to convert an event to valid xml" do
    @event_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of events to valid xml" do
    [@event_a,@event_b].should convert_to_valid_caren_array_xml
  end

end
