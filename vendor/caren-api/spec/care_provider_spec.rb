require 'spec_helper'

describe "CareProvider", "converting to xml" do

  before do
    @care_provider_a = Caren::CareProvider.new( :name => "Zuwe",
      :telephone => "112",
      :website => "http://www.zuwe.nl",
      :email => "zuwe@example.com",
      :address_line => "Sesamestreet 1",
      :url_shortcut => "zuwe",
      :time_zone => "Amsterdam",
      :resolution => "exact",
      :bandwidth => "0",
      :min_start => "07:00",
      :max_start => "00:00",
      :show_employee_name_as_title => true,
      :show_employee_names => true,
      :communication => true )

    @care_provider_b = Caren::CareProvider.new( :name => "Aveant",
      :telephone => "112",
      :website => "http://www.aveant.nl",
      :email => "aveant@example.com",
      :address_line => "Sesamestreet 1",
      :url_shortcut => "zuwe",
      :time_zone => "Amsterdam",
      :resolution => "exact",
      :bandwidth => "0",
      :min_start => "07:00",
      :max_start => "00:00",
      :show_employee_name_as_title => true,
      :show_employee_names => true,
      :communication => true )
  end

  it "should be able to convert a person to valid xml" do
    @care_provider_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of people to valid xml" do
    [@care_provider_a,@care_provider_b].should convert_to_valid_caren_array_xml
  end

  it "should be able to generate a proper xml file to update the logo" do
    filename = "spec/fixtures/bacon.jpg"
    xml = @care_provider_a.to_logo_xml filename
    doc = REXML::Document.new(xml)
    doc.elements.each('care_provider/logo') do |cp|
      cp.attributes["name"].should == "bacon.jpg"
      cp.attributes["content-type"].should == "image/jpeg"
      cp.text.should == Base64.encode64(File.open(filename).read)
    end
  end

end

describe "CareProvider" do

  it "should be able to convert a image file path to a hash suited for xml conversion" do
    filename = "spec/fixtures/bacon.jpg"
    logo = Caren::CareProvider.hash_from_image( filename )
    logo[:content_type].should == "image/jpeg"
    logo[:name].should == "bacon.jpg"
    logo[:content].should == File.open(filename).read
  end

end

describe "CareProvider", "REST methods" do

  before do
    care_provider = File.read("spec/fixtures/caren_care_provider.xml")
    care_providers = File.read("spec/fixtures/caren_care_providers.xml")
    care_providers_search = File.read("spec/fixtures/caren_care_providers_search.xml")

    care_provider_url = Caren::Api.session.url_for( Caren::CareProvider.resource_url(1) )
    care_providers_url = Caren::Api.session.url_for( Caren::CareProvider.resource_url )
    search_url = Caren::Api.session.url_for( "#{Caren::CareProvider.resource_url}?key=url-shortcut&value=pantein" )

    timestamp = DateTime.now.to_i

    FakeWeb.register_uri(:put, care_provider_url, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp) )
    FakeWeb.register_uri(:get, care_provider_url, :body => care_provider, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,care_provider) )
    FakeWeb.register_uri(:get, care_providers_url, :body => care_providers, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,care_providers) )
    FakeWeb.register_uri(:get, search_url, :body => care_providers_search, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,care_providers_search) )
  end

  it "should be able to update a care provider" do
    lambda{ Caren::CareProvider.new( :id => 1, :name => "Test" ).update( Caren::Api.session ) }.should_not raise_error
  end

  it "should be able to update the logo for a care provider" do
    lambda{ Caren::CareProvider.new( :id => 1 ).update_logo( "spec/fixtures/bacon.jpg", Caren::Api.session ) }.should_not raise_error
  end

  it "should be able to search for a specific care provider" do
    care_providers = Caren::CareProvider.search :url_shortcut, "pantein", Caren::Api.session
    care_providers.should have(1).things
    care_providers.first.name.should == "Pantein"
    care_providers.first.url_shortcut.should == "pantein"
  end

  it "should be able to find all care providers" do
    care_providers = Caren::CareProvider.all Caren::Api.session
    care_providers.should have(2).things
    care_providers.first.name.should == "Demo"
    care_providers.first.url_shortcut.should == "demo"
  end

  it "should be able to find one care providers" do
    care_provider = Caren::CareProvider.find 1, Caren::Api.session
    care_provider.name.should == "Demo"
  end

end
