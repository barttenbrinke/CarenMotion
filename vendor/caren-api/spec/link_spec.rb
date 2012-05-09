require 'spec_helper'

describe "Link", "converting to xml" do

  before do
    @link_a = Caren::Link.new( :patient_number => "12345" )
    @link_b = Caren::Link.new( :patient_number => "67890" )
  end

  it "should be able to convert a link to valid xml" do
    @link_a.should convert_to_valid_caren_xml
  end

  it "should be able to convert an array of links to valid xml" do
    [@link_a,@link_b].should convert_to_valid_caren_array_xml
  end

end

describe "Link", "REST methods" do

  before do
    link  = File.read("spec/fixtures/caren_link.xml")
    links  = File.read("spec/fixtures/caren_links.xml")
    search = File.read("spec/fixtures/caren_links_search.xml")

    link_url  = Caren::Api.session.url_for(Caren::Link.resource_url(1))
    links_url  = Caren::Api.session.url_for(Caren::Link.resource_url)
    search_url = Caren::Api.session.url_for("#{Caren::Link.resource_url}?key=external-id&value=1")

    timestamp = DateTime.now.to_i

    FakeWeb.register_uri(:get, link_url, :body => link, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,link) )
    FakeWeb.register_uri(:get, links_url, :body => links, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,links) )
    FakeWeb.register_uri(:get, search_url, :body => search, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,search) )
    FakeWeb.register_uri(:post, links_url, :status => 201, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp) )
  end

  it "should be able to create a new link using the API" do
    lambda{ Caren::Link.new( :patient_number => "12345" ).create(Caren::Api.session) }.should_not raise_error
  end

  it "should be find all links using the API" do
    links = Caren::Link.all(Caren::Api.session)
    links.should have(3).things
    links.first.id.should == 1
    links.first.status.should == "confirmed"
    links.first.external_id.should == "1"
    links.first.person_name.should == "Andre Foeken"
    links.first.person_id.should == 3
  end

  it "should be find all links using the API" do
    link = Caren::Link.find(1,Caren::Api.session)
    link.id.should == 1
  end

  it "should be find a specific link using the API" do
    links = Caren::Link.search(:external_id, 1, Caren::Api.session)
    links.should have(1).thing
  end

end
