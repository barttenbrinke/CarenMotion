class Caren::ExternalMessage < Caren::Base

  def self.keys
    [ :id,                  # Integer (Caren message id)
      :person_name,         # String (Andre Foeken)
      :person_id,           # Integer (Caren person id)
      :external_person_id,  # String (Your person id)
      :care_provider_id,    # Integer (Caren CP id)
      :body,                # Text
      :external_id,         # String (Your message id)
      :in_reply_to_id,      # Integer (Caren message id)
      :in_reply_to_type,    # The type of message this is a reply to. (Always ExternalMessage if reply is set)
      :subject_id           # Integer (Caren person id)
    ] + super
  end

  def self.all subject_id, session
    from_xml session.get(self.resource_url(subject_id))
  end

  def self.find subject_id, id, session
    from_xml session.get(self.resource_url(subject_id,id))
  end

  def create session
    self.class.from_xml session.post self.class.resource_url(self.subject_id), self.to_xml
  end

  def delete session
    session.delete self.class.resource_url(self.subject_id,self.id)
  end

  def self.array_root
    :external_messages
  end

  def self.node_root
    :external_message
  end

  def as_xml
    { :person_name => self.person_name,
      :external_person_id => self.external_person_id,
      :body => self.body,
      :external_id => self.external_id,
      :in_reply_to_id => self.in_reply_to_id }
  end

  def self.resource_location
    "/api/pro/people/%i/external_messages"
  end

  private

  def resource_url subject_id, id=nil
    self.class.resource_url(subject_id,id)
  end

  def self.resource_url subject_id, id=nil
    "#{self.resource_location % subject_id}#{id}"
  end

end
