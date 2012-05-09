require 'spec_helper'

describe "Client", "converting to xml" do

  before do
    @client_a = Caren::Client.new( :external_id => 1,
                                   :uid => "ABC123",
                                   :first_name => "Andre",
                                   :last_name => "Foeken",
                                   :male => true,
                                   :date_of_birth => 80.years.ago.to_date,
                                   :address_street => "Sesamestreet 1",
                                   :address_zipcode => "7500AA",
                                   :address_city => "Groenlo",
                                   :address_country => "The Netherlands" )

    @client_b = Caren::Client.new( :external_id => 2,
                                   :uid => "ABC456",
                                   :first_name => "Oscar",
                                   :last_name => "Foeken",
                                   :male => true,
                                   :date_of_birth => 80.years.ago.to_date,
                                   :address_street => "Sesamestreet 1",
                                   :address_zipcode => "7500AA",
                                   :address_city => "Groenlo",
                                   :address_country => "The Netherlands" )
  end

  it "should be able to convert a client to valid xml" do
    @client_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of people to valid xml" do
    [@client_a,@client_b].should convert_to_valid_caren_array_xml
  end

end
