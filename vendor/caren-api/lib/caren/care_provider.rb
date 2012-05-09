# The CareProvider class enables the following features:
# * Update care provider settings
# * Get a list of care providers
# * Search for a specific care provider based on key/value
class Caren::CareProvider < Caren::Base

  def self.keys
    [ :id,                          # Integer (The id of this CP inside Caren)
      :name,                        # String
      :telephone,                   # String
      :website,                     # String
      :email,                       # String
      :address_line,                # String (Kerkstraat 1, 7522AH, Enschede)
      :logo,                        # String
      :url_shortcut,                # String
      :time_zone,                   # String (Amsterdam)
      :resolution,                  # String (exact,daypart,range)
      :bandwidth,                   # Integer (60 -> 60 minutes)
      :show_employee_names,         # Boolean
      :show_employee_photos,        # Boolean
      :max_start,                   # String (23:00)
      :min_start,                   # String (07:00)
      :show_employee_name_as_title, # Boolean
      :communication,               # Boolean
      :selective_communication,     # Boolean
      :api_key,                     # String, RSA public key
      :linkable,                    # Boolean
      :closed_beta,                 # Boolean
      :locale,                      # String
      :lat,
      :lng
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

  def update session
    self.class.from_xml session.put(self.resource_url(self.id), self.to_xml)
  end

  def update_logo logo_hash_or_path, session
    self.class.from_xml session.put(self.resource_url(self.id), self.to_logo_xml(logo_hash_or_path))
  end

  def as_xml
    { :name => self.name,
      :telephone => self.telephone,
      :website => self.website,
      :email => self.email,
      :address_line => self.address_line,
      :url_shortcut => self.url_shortcut,
      :time_zone => self.time_zone,
      :resolution => self.resolution,
      :bandwidth => self.bandwidth,
      :min_start => self.min_start,
      :max_start => self.max_start,
      :show_employee_name_as_title => self.show_employee_name_as_title,
      :show_employee_names => self.show_employee_names,
      :show_employee_photos => self.show_employee_photos,
      :communication => self.communication,
      :selective_communication => self.selective_communication,
      :api_key => self.api_key,
      :closed_beta => self.closed_beta,
      :locale => self.locale,
      :lat => self.lat,
      :lng => self.lng
    }
  end

  def to_logo_xml logo_hash_or_path
    builder = Builder::XmlMarkup.new
    logo = self.class.hash_from_image(logo_hash_or_path)
    xml = builder.care_provider do |care_provider|
      care_provider.tag!("logo", Base64.encode64(logo[:content]), "name" => logo[:name], "content-type" => logo[:content_type], "type" => "file" ) if logo
    end
  end

  def self.resource_location
    "/api/pro/care_providers"
  end

  def self.array_root
    :care_providers
  end

  def self.node_root
    :care_provider
  end

end
