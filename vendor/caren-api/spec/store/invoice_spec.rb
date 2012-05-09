require 'spec_helper'

describe "Store::Invoice", "converting to xml" do

  before do
    @line_item_a = Caren::Store::LineItem.new( :price_in_cents => 1900 )
    @line_item_b = Caren::Store::LineItem.new( :price_in_cents => 1499 )
    @address = Caren::Store::Address.new( :full_name => "Andre Foeken")
    @invoice_a = Caren::Store::Invoice.new( :reference => "NW-05463-12-A", :line_items => [@line_item_a,@line_item_b], :shipping_address => @address )
    @invoice_b = Caren::Store::Invoice.new( :reference => "NW-05463-12-B", :billing_address => @address )
  end

  it "should be able to convert a line item to valid xml" do    
    # A bit nasty but it works
    new_object = Caren::Store::Invoice.from_xml( @invoice_a.to_xml )
    new_object.shipping_address.attributes.should == @invoice_a.shipping_address.attributes
    
    count = 0
    new_object.line_items.each do |li|
      li.attributes.should == @invoice_a.line_items[count].attributes
      count += 1
    end
    
    @invoice_a.attributes.delete :shipping_address
    @invoice_a.attributes.delete :line_items
    
    new_object.attributes.delete :shipping_address
    new_object.attributes.delete :line_items
    
    new_object.attributes.should == @invoice_a.attributes
  end
  
  it "should generate correct mark as paid xml" do
    hash = Hash.from_xml( Caren::Store::Invoice.mark_as_paid_xml("cash","test") )
    hash["invoice"]["payment_method"].should == "cash"
    hash["invoice"]["payment_method_description"].should == "test"
  end

end

describe "Store::Invoice", "REST methods" do

  before do
    invoice = File.read("spec/fixtures/caren_invoice.xml")
    invoices = File.read("spec/fixtures/caren_invoices.xml")
    invoices_search = File.read("spec/fixtures/caren_invoices_search.xml")

    invoice_url = Caren::Api.session.url_for( Caren::Store::Invoice.resource_url(17) )
    invoices_url = Caren::Api.session.url_for( Caren::Store::Invoice.resource_url )
    invoices_search_url = Caren::Api.session.url_for( "#{Caren::Store::Invoice.resource_url}?key=reference&value=NW-05463-12-0" )
    timestamp = DateTime.now.to_i

    FakeWeb.register_uri(:get, invoices_url, :body => invoices, :signature => Caren::Api.session.sign(timestamp,nil,invoices), :timestamp => timestamp )
    FakeWeb.register_uri(:get, invoices_search_url, :body => invoices_search, :signature => Caren::Api.session.sign(timestamp,nil,invoices_search), :timestamp => timestamp )
    FakeWeb.register_uri(:get, invoice_url, :body => invoice, :signature => Caren::Api.session.sign(timestamp,nil,invoice), :timestamp => timestamp )
    
    FakeWeb.register_uri(:post, invoices_url, :status => 201, :signature => Caren::Api.session.sign(timestamp), :timestamp => timestamp )
    FakeWeb.register_uri(:put, invoice_url, :body => invoice, :signature => Caren::Api.session.sign(timestamp,nil,invoice), :timestamp => timestamp )
    FakeWeb.register_uri(:delete, invoice_url, :signature => Caren::Api.session.sign(timestamp), :timestamp => timestamp )
  end

  it "should be able to find all invoices" do
    invoices = Caren::Store::Invoice.all Caren::Api.session
    invoices.should have(3).things
    invoices.first.customer_email.should == "jenny@example.com"
  end

  it "should be able to find one invoice" do
    invoice = Caren::Store::Invoice.find 17, Caren::Api.session
    invoice.customer_email.should == "jenny@example.com"
  end

  it "should be able to search for a specific invoice" do
    billables = Caren::Store::Invoice.search :reference, "NW-05463-12-0", Caren::Api.session
    billables.should have(1).things
    billables.first.reference.should == "NW-05463-12-0"
  end

  it "should be able to create an invoice" do
    lambda{ Caren::Store::Invoice.new( :reference => "JL-1" ).create(Caren::Api.session) }.should_not raise_error
  end
  
  it "should be able to update an invoice" do
    lambda{ Caren::Store::Invoice.new( :id => 17, :reference => "JL-1" ).update(Caren::Api.session) }.should_not raise_error
  end

  it "should be able to delete an external invoice" do
    lambda{ Caren::Store::Invoice.new( :id => 17 ).delete(Caren::Api.session) }.should_not raise_error
  end

end
