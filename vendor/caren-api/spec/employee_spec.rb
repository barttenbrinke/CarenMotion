require 'spec_helper'

describe "Employee", "converting to xml" do

  before do
    @employee_a = Caren::Employee.new( :external_id => 1,
                                   :first_name => "Andre",
                                   :last_name => "Foeken",
                                   :bio => "Aap")

    @employee_b = Caren::Employee.new( :external_id => 2,                                   
                                   :first_name => "Oscar",
                                   :last_name => "Foeken",
                                   :bio => "Noot")
  end

  it "should be able to convert a employee to valid xml" do
    @employee_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of employee to valid xml" do
    [@employee_a,@employee_b].should convert_to_valid_caren_array_xml
  end

end
