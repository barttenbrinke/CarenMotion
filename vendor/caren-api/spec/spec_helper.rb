require 'rubygems'
require 'caren-api'
require 'rspec'
require 'fakeweb'
require 'capybara'

class Integer

  def euros
    self*100
  end

end

# For the tests we need to know both the public and private key, so we share them here.
# We also use a smaller key here, to make the tests faster.
new_private_key = Caren::Api.generate_private_key( 512 )
Caren::Api.session = Caren::Api.new( new_private_key, "http://example.com", new_private_key.public_key )

FakeWeb.allow_net_connect = false

RSpec::Matchers.define :convert_to_valid_caren_xml do
  match do |instance|
    hash = Hash.from_xml(instance.to_xml)
    keys = instance.as_xml.keys.map(&:to_s)
    (hash[instance.class.node_root.to_s].keys - keys).should be_empty
    keys.map do |key|
      hash[instance.class.node_root.to_s][key].to_s == instance.send(key.to_sym).to_s
    end.flatten.inject(&:&)
  end
end

RSpec::Matchers.define :convert_to_valid_caren_array_xml do
  match do |array|
    hash = Hash.from_xml( array.first.class.to_xml(array) )
    hash.keys.should eql [array.first.class.array_root.to_s]
    array.each do |obj|
      obj.should convert_to_valid_caren_xml
    end
  end
end

RSpec.configure do |config|

end
