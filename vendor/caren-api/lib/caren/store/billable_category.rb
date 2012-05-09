class Caren::Store::BillableCategory < Caren::Base

  def self.keys
    [ :id,                    # Integer (Id of this category in Caren)
      :name,                  # String
      :description,           # Text
      :icon,                  # String
      :billable_category_id    # Integer (Parent category; Caren id; Nil for root node)
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

  def self.array_root
    :billable_categories
  end

  def self.node_root
    :billable_category
  end

  def self.resource_location
    "/api/pro/store/billable_categories"
  end

end
