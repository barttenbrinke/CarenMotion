class Caren::Store::Invoice < Caren::Base

  def self.keys
    [:id,                           # Integer (Caren id)
     :external_id,                  # Integer (Your id)
     :person_id,                    # Integer (Caren person id)
     :external_person_id,           # Integer (Your person id)
     :currency,                     # String
     :reference,                    # String
     :requires_account,             # Boolean
     :requires_payment,             # Boolean
     :access_token,                 # String
     :invoice_url,                  # String
     :payment_url,                  # String
     :customer_email,               # String
     :email_status,                 # String (unsent,sent,reminder_sent)
     :status,                       # String (draft open paid late revoked)
     :payment_method,               # String
     :payment_method_description,   # String
     :billing_address,              # Store::Address(:purpose => 'billing')
     :shipping_address,             # Store::Address(:purpose => 'shipping')
     :line_items,                   # Array of Store::LineItem
     :invoiced_at,                  # Datetime
     :paid_at,                      # Datetime
    ] + super
  end
  
  def self.search key, value, session
    from_xml session.get( self.search_url(key,value) )
  end

  def self.find id, session
    from_xml session.get(self.resource_url(id))
  end

  def self.all_with_filter filter, session
    from_xml session.get(self.filter_url(filter))
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
  
  def delete session
    session.delete self.class.resource_url(self.id)
  end
  
  def mark_as_paid method, description, session
    self.class.from_xml session.post(self.class.mark_as_paid_url(self.id), self.class.mark_as_paid_xml(method,description))
  end
  
  def mark_as_revoked session
    self.class.from_xml session.post(self.class.mark_as_revoked_url(self.id), nil)
  end
  
  def mark_as_open session
    self.class.from_xml session.post(self.class.mark_as_open_url(self.id), nil)
  end
  
  def self.mark_as_paid_xml method=nil, description=nil
    body = { :payment_method_description => description, :payment_method => method }
    return body.to_xml( :root => (self.node_root || self.class.node_root) )
  end

  def as_xml
    # make sure we have the correct address nodes here
    billing_address.purpose = 'billing' if billing_address
    shipping_address.purpose = 'shipping' if shipping_address
    
    {
     :status => self.status,
     :external_id => self.external_id,
     :person_id => self.person_id,
     :external_person_id => self.external_person_id,
     :reference => self.reference,
     :requires_account => self.requires_account,
     :requires_payment => self.requires_payment,
     :customer_email => self.customer_email,
     :payment_method => self.payment_method,
     :payment_method_description => self.payment_method_description,
     :billing_address => self.billing_address,
     :shipping_address => self.shipping_address,
     :line_items => self.line_items,
     :invoiced_at => self.invoiced_at,
     :paid_at => self.paid_at 
    }
  end
    
  def self.init_dependent_objects invoice
    
    if invoice.shipping_address.is_a?(Hash)
      invoice.shipping_address = Caren::Store::Address.new( invoice.shipping_address.merge(:purpose => 'shipping') )
    end
    
    if invoice.billing_address.is_a?(Hash)
      invoice.billing_address = Caren::Store::Address.new( invoice.billing_address.merge(:purpose => 'billing') )
    end
    
    if invoice.line_items.is_a?(Array)
      invoice.line_items = invoice.line_items.map do |li|
        Caren::Store::LineItem.new(li) if li.is_a?(Hash)
      end
    end
    
    return invoice
  end

  def self.array_root
    :invoices
  end

  def self.node_root
    :invoice
  end
  
  def self.filter_url filter
    "#{self.resource_url}?filter=#{filter}"
  end

  def self.mark_as_revoked_url id
    "#{self.resource_url(id)}/mark_as_revoked"
  end
  
  def self.mark_as_open_url id
    "#{self.resource_url(id)}/mark_as_open"
  end
  
  def self.mark_as_paid_url id
    "#{self.resource_url(id)}/mark_as_paid"
  end

  def self.resource_location
    "/api/pro/store/invoices"
  end

end
