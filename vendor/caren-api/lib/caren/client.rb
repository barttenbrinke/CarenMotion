class Caren::Client < Caren::Base

  def self.keys
    [ :external_id,     # String (Your client id)
      :uid,             # String (Customer unique code)
      :first_name,      # String
      :last_name,       # String
      :male,            # Boolean
      :date_of_birth,   # Date
      :address_street,  # String
      :address_zipcode, # String
      :address_city,    # String
      :address_country  # String
    ] + super
  end

  def self.array_root
    :clients
  end

  def self.node_root
    :client
  end

end
