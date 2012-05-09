class Caren::EventSlotContainer < Caren::Base

  def self.keys
    [ :employee,
      :event_slots
    ]
  end

  def self.array_root
   :event_slot_containers
  end

  def self.node_root
   :event_slot_container
  end

end