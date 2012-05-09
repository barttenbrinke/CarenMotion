# This class is just an intermediate for representing potential event occurences.
class Caren::Store::Address < Caren::Base

  def self.keys
    [ :full_name,                 # String
      :address_line_1,            # String
      :address_line_2,            # String
      :city,                      # String
      :state_province_or_region,  # String
      :zip,                       # String
      :country,                   # String
      :purpose,                   # String (shipping or billing)
    ]
  end

  def self.array_root
   :addresses
  end

  def as_xml
    {
      :full_name => self.full_name,
      :address_line_1 => self.address_line_1,
      :address_line_2 => self.address_line_2,
      :city => self.city,
      :state_province_or_region => self.state_province_or_region,
      :zip => self.zip,
      :country => self.country
    }
  end

  def node_root
    case self.purpose
    when "shipping"
      :shipping_address
    when "billing"
      :billing_address
    else
      self.class.node_root
    end
  end

  def self.node_root
   :address
  end

end