require 'spec_helper'

describe "Caren", "signature checks" do

  before do
    @incorrect_url = "/test_with_incorrect_signature"
    @correct_url   = "/test_with_correct_signature"
    @error_url     = "/test_with_errors"

    FakeWeb.register_uri(:get, Caren::Api.session.url_for(@incorrect_url), :body => "TEST", :signature => "[INCORRECT]" )
    FakeWeb.register_uri(:post, Caren::Api.session.url_for(@incorrect_url), :body => "TEST", :signature => "[INCORRECT]" )
    FakeWeb.register_uri(:put, Caren::Api.session.url_for(@incorrect_url), :body => "TEST", :signature => "[INCORRECT]" )
    FakeWeb.register_uri(:delete, Caren::Api.session.url_for(@incorrect_url), :body => "TEST", :signature => "[INCORRECT]" )

    FakeWeb.register_uri(:get, Caren::Api.session.url_for(@correct_url), :body => "TEST", :signature => Caren::Api.session.sign("TEST") )
    FakeWeb.register_uri(:post, Caren::Api.session.url_for(@correct_url), :body => "TEST", :signature => Caren::Api.session.sign("TEST") )
    FakeWeb.register_uri(:put, Caren::Api.session.url_for(@correct_url), :body => "TEST", :signature => Caren::Api.session.sign("TEST") )
    FakeWeb.register_uri(:delete, Caren::Api.session.url_for(@correct_url), :body => "TEST", :signature => Caren::Api.session.sign("TEST") )

    errors = File.read "spec/fixtures/caren_care_provider_validation.xml"
    unauth = File.read "spec/fixtures/caren_unauthorized.xml"
    FakeWeb.register_uri(:get, Caren::Api.session.url_for(@error_url), :status => 406, :body => errors, :signature => Caren::Api.session.sign(errors) )
    FakeWeb.register_uri(:post, Caren::Api.session.url_for(@error_url), :status => 406, :body => errors, :signature => Caren::Api.session.sign(errors) )
    FakeWeb.register_uri(:put, Caren::Api.session.url_for(@error_url), :status => 406, :body => errors, :signature => Caren::Api.session.sign(errors) )
    FakeWeb.register_uri(:delete, Caren::Api.session.url_for(@error_url), :status => 403, :body => unauth, :signature => Caren::Api.session.sign(unauth) )
  end

  it "should not accept result swith an incorrect signature" do
    lambda{ Caren::Api.session.get @incorrect_url }.should raise_error
    lambda{ Caren::Api.session.post @incorrect_url, "" }.should raise_error
    lambda{ Caren::Api.session.put @incorrect_url, "" }.should raise_error
    lambda{ Caren::Api.session.delete @incorrect_url }.should raise_error
  end

  it "should accept results with a correct signature" do
    lambda{ Caren::Api.session.get @correct_url }.should_not raise_error
    lambda{ Caren::Api.session.post @correct_url, "" }.should_not raise_error
    lambda{ Caren::Api.session.put @correct_url, "" }.should_not raise_error
    lambda{ Caren::Api.session.delete @correct_url }.should_not raise_error
  end

  it "should be able to handle server side errors" do

    lambda{ Caren::Api.session.get @error_url }.should raise_error(Caren::Exceptions::ServerSideError)
    lambda{ Caren::Api.session.put @error_url, "" }.should raise_error(Caren::Exceptions::ServerSideError)
    lambda{ Caren::Api.session.post @error_url, "" }.should raise_error(Caren::Exceptions::ServerSideError)
    lambda{ Caren::Api.session.delete @error_url }.should raise_error(Caren::Exceptions::ServerSideError)

  end

  it "should be able to handle authorization errors" do
    begin
      Caren::Api.session.delete @error_url
    rescue Caren::Exceptions::ServerSideError => e
      e.errors.should have(1).things
      e.errors.first.class.should == Caren::Error
      e.errors.first.category.should == "unauthorized"
      e.errors.first.message.should == "You are not allowed to perform this action."
    end
  end

  it "should be able to handle validation errors" do
    begin
      Caren::Api.session.get @error_url
    rescue Caren::Exceptions::ServerSideError => e
      e.errors.should have(1).things
      e.errors.first.class.should == Caren::ValidationError
      e.errors.first.message.should == "has already been taken"
      e.errors.first.field.should == :url_shortcut
      e.errors.first.to_s.should == "`url_shortcut` has already been taken"
    end
  end

  it "should be able to handle incoming xml from caren" do
    incoming = File.read "spec/fixtures/incoming.xml"
    timestamp = DateTime.now.to_i
    results  = Caren::Api.session.incoming(incoming, Caren::Api.session.sign(timestamp, nil, incoming), timestamp )
    results.should have(4).things
    external_messages = results.select{ |x| x.is_a?(Caren::ExternalMessage) }
    external_messages.first.id.should == 1
    links = results.select{ |x| x.is_a?(Caren::Link) }
    links.last.id.should == 3
  end

  it "should be able to parse just one incoming object from xml from caren" do
    incoming = File.read "spec/fixtures/incoming_single_object.xml"
    object = Caren::Api.session.parse_object(incoming)
    object.body.should == 'Expecting this to work somehow ...'
    object.id.should == 1
  end

end
