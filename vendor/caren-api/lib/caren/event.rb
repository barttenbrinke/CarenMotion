# This class is just an intermediate for exporting events to Caren.
# It has the correct format for exports.
class Caren::Event < Caren::Base

  def self.keys
    [ :external_id,       # String Unique identifying string (Your event id)
      :name,              # String
      :comment,           # String
      :start,             # String (14:00)
      :duration,          # Integer
      :valid_from,        # Date
      :valid_to,          # Date
      :person_first_name, # String
      :person_last_name,  # String
      :person_male,       # Boolean
      :external_person_id,# String (Your person id)
      :source             # String (remote_schedule,remote_realisation)
    ] + super
  end

  def self.array_root
   :events
  end

  def self.node_root
   :event
  end

end
