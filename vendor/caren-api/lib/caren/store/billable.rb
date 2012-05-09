class Caren::Store::Billable < Caren::Base

  def self.keys
    [ :id,                              # Integer (Id of this product in Caren)
      :external_id,                     # Integer (Your id)
      :name,                            # String
      :description,                     # Text
      :care_provider_id,                # Integer (Care provider id)
      :billable_category_id,            # Integer (Reference to product category; Caren id)
      :photo,                           # String
      :in_store,                        # Boolean (Use in store)
      :unit,                            # String (piece, minute, hour)
      :price_with_sales_tax_in_cents,   # Integer
      :currency,                        # String (EUR,USD)
      :rounding,                        # Integer (in seconds)
      :min_amount,                      # Integer (in seconds)
      :default_amount,                  # Integer (in seconds)
      :piece_duration,                  # Integer (in seconds)
      :sales_tax_in_promillage,         # Integer
      :type,                            # String (Store::Product,Store::Service,Store::ChatSession)
      :status,                          # String (pending, active)
      :send_reminder_in_advance,        # Integer (in seconds)
      :plannable_by_subject,            # Boolean
      :plannable_margin_before,         # Integer (in seconds)
      :plannable_margin_after,          # Integer (in seconds)
      :plannable_max_duration,          # Integer (in seconds)
      :plannable_comment_above,         # Text
      :plannable_description_required,  # Boolean
      :available                        # Boolean
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

  def create session
    self.class.from_xml session.post(self.resource_url, self.to_xml)
  end

  def update session
    self.class.from_xml session.put(self.resource_url(self.id), self.to_xml)
  end

  def update_photo photo_hash_or_path, session
    self.class.from_xml session.put(self.resource_url(self.id), self.to_photo_xml(photo_hash_or_path))
  end
  
  def delete session
    session.delete self.class.resource_url(self.id)
  end

  def as_xml
    { :name => self.name,
      :description => self.description,
      :billable_category_id => self.billable_category_id,
      :in_store => self.in_store,
      :unit => self.unit,
      :photo => self.photo,
      :price_with_sales_tax_in_cents => self.price_with_sales_tax_in_cents,
      :currency => self.currency,
      :type => self.type,
      :rounding => self.rounding,
      :sales_tax_in_promillage => self.sales_tax_in_promillage,
      :external_id => self.external_id,
      :piece_duration => self.piece_duration,
      :min_amount => self.min_amount,
      :default_amount => self.default_amount,
      :send_reminder_in_advance => self.send_reminder_in_advance,
      :plannable_by_subject => self.plannable_by_subject,
      :plannable_margin_before => self.plannable_margin_before,
      :plannable_margin_after => self.plannable_margin_after,
      :plannable_max_duration => self.plannable_max_duration,
      :plannable_comment_above => self.plannable_comment_above,
      :plannable_description_required => self.plannable_description_required,
      :available => self.available
    }
  end

  def to_photo_xml photo_hash_or_path
    builder = Builder::XmlMarkup.new
    photo = self.class.hash_from_image(photo_hash_or_path)
    xml = builder.billable do |billable|
      billable.tag!("photo", Base64.encode64(photo[:content]), "name" => photo[:name], "content-type" => photo[:content_type], "type" => "file" ) if photo
    end
  end

  def self.array_root
    :billables
  end

  def self.node_root
    :billable
  end

  def self.resource_location
    "/api/pro/store/billables"
  end

end
