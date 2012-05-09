# This class is just an intermediate for representing potential event occurences.
class Caren::EventSlot < Caren::Base

  def self.keys
    [ :date,              # Date
      :start,             # String
      :duration,          # Integer
    ]
  end

  def self.array_root
   :event_slots
  end

  def self.node_root
   :event_slot
  end

end