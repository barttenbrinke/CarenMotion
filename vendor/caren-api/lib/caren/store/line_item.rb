class Caren::Store::LineItem < Caren::Base

  def self.keys
    [:id,                       # Integer (Caren id)
     :external_id,              # Integer (Your id)
     :sku,                      # String
     :invoice_id,               # Integer (caren invoice id)
     :billable_id,              # Integer (caren billable id)
     :currency,                 # String (EUR)
     :description,              # String
     :discount_in_cents,        # Integer
     :discount_in_promillage,   # Integer (190 = 19%)
     :commission_in_cents,      # Integer
     :commission_in_promillage, # Integer (70 = 7%)
     :price_in_cents,           # Integer
     :quantity,                 # Integer
     :unit,                     # String
     :sales_tax_in_cents,       # Integer
     :sales_tax_in_promillage,  # Integer
    ] + super
  end
  
  def delete session
    session.delete self.class.resource_url(self.id)
  end
  
  def as_xml
    {
      :id => self.id,
      :external_id => self.external_id,
      :sku => self.sku,
      :billable_id => self.billable_id,
      :currency => self.currency,
      :description => self.description,
      :discount_in_cents => self.discount_in_cents,
      :discount_in_promillage => self.discount_in_promillage,
      :price_in_cents => self.price_in_cents,
      :quantity => self.quantity,
      :unit => self.unit,
      :sales_tax_in_cents => self.sales_tax_in_cents,
      :sales_tax_in_promillage => self.sales_tax_in_promillage
    }
  end

  def self.array_root
    :line_items
  end

  def self.node_root
    :line_item
  end

  def self.resource_location
    "/api/pro/store/line_items"
  end

end
