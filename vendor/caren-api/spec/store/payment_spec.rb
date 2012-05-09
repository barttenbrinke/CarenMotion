require 'spec_helper'

describe "Store::Payment", "REST methods" do

  before do
    payments = File.read("spec/fixtures/caren_payments.xml")
    payments_search = File.read("spec/fixtures/caren_payments_search.xml")

    payments_url = Caren::Api.session.url_for( Caren::Store::Payment.resource_url )
    search_url = Caren::Api.session.url_for( "#{Caren::Store::Payment.resource_url}?key=status&value=failed" )

    timestamp = DateTime.now.to_i

    FakeWeb.register_uri(:get, payments_url, :body => payments, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,payments) )
    FakeWeb.register_uri(:get, search_url, :body => payments_search, :timestamp => timestamp, :signature => Caren::Api.session.sign(timestamp,nil,payments_search) )
  end

  it "should be able to search for a specific billable category" do
    payments_search = Caren::Store::Payment.search :status, "failed", Caren::Api.session
    payments_search.should have(1).things
    payments_search.first.status.should == "failed"
  end

  it "should be able to find all billable category" do
    payments = Caren::Store::Payment.all Caren::Api.session
    payments.should have(2).things
    payments.first.status.should == "paid"
  end

end
