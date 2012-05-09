class Caren::Store::Payment < Caren::Base

  def self.keys
    [:id,                 # Integer (Caren id)
     :invoice_id,         # Integer (Caren invoice id)
     :person_id,          # Integer (Caren person id)
     :auth_code,          # String
     :psp_reference,      # String
     :refusal_reason,     # String
     :result_code,        # String
     :status,             # String (new, pending,paid,failed)
     :currency,           # String (EUR)
     :amount_in_cents,    # Integer
     :gateway,            # String (ideal)
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

  def self.array_root
    :payments
  end

  def self.node_root
    :payment
  end

  def self.filter_url filter
    "#{self.resource_url}?filter=#{filter}"
  end

  def self.resource_location
    "/api/pro/store/payments"
  end

end
