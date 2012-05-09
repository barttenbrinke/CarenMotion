class Caren::Employee < Caren::Base

  def self.keys
    [ :external_id,     # String (Your client id)
      :first_name,      # String
      :last_name,       # String
      :bio,             # Text
      :photo            # String
    ]
  end

  def self.array_root
    :employees
  end

  def self.node_root
    :employee
  end

end
