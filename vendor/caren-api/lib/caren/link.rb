class Caren::Link < Caren::Base

  def self.keys
    [:id,               # Integer (Caren id)
     :person_name,      # String (Caren person name)
     :care_provider_id, # Integer
     :person_id,        # String (Caren person id)
     :person_photo,     # String (url of photo)
     :patient_number,   # String (12345)
     :external_id,      # String (Your person id)
     :status            # String (pending,confirmed,cancelled)
    ] + super
  end

  def self.search key, value, session
    from_xml session.get( self.search_url(key,value) )
  end

  def self.find id, session
    from_xml session.get(self.resource_url(id))
  end

  def self.all session
    from_xml session.get(self.resource_url)
  end

  # Request to create a new link. Example:
  # Caren::Link.new( :patient_number => 1234 ).create
  def create session
    self.class.from_xml session.post(self.resource_url, self.to_xml)
  end

  def as_xml
    { :patient_number => self.patient_number,
      :external_id => self.external_id }
  end

  def self.array_root
    :links
  end

  def self.node_root
    :link
  end

  def self.resource_location
    "/api/pro/links"
  end

end
