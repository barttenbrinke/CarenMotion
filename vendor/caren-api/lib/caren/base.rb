# The base class for all API objects that can be converted to XML.
# The class provides basic functionality to convert objects to and from xml based
# on the default Caren API format.
class Caren::Base

  attr_accessor :attributes, :original_xml

  # Basic initializer, handles quick setting of passed attributes.
  def initialize args={}, xml=""
    self.original_xml = xml
    self.attributes = {}
    self.class.keys.each do |key|
      if args.has_key?(key)
        self.attributes[key] = args[key]
      elsif args.has_key?(key.to_s)
        self.attributes[key] = args[key.to_s]
      else
        self.attributes[key] = nil
      end
    end
    # We want to use #id and #type (in Ruby 1.8.x we need to undef it)
    self.instance_eval('undef id') if self.respond_to?(:id)
    self.instance_eval('undef type') if self.respond_to?(:type)
  end

  # List of available attributes for this object
  def self.keys
    [ :updated_at, :created_at, :action ]
  end

  # Root name of the XML array of objects
  def self.array_root
    :objects
  end

  # Name of each XML if converted to XML
  def self.node_root
    :object
  end
  
  # Override this for instance specific node roots
  def node_root
    nil
  end

  # The relative location of this resource.
  def self.resource_location
    raise "No resource location found"
  end

  # Convert an array of these objects to XML
  def self.to_xml array
    array.to_xml( :root => self.array_root )
  end

  # this method is called for each parsed object. So subclasses can add extra parsing later on.
  def self.init_dependent_objects object
    object
  end

  # Convert a XML string to a single object or an array of objects
  def self.from_xml xml
    return nil if xml == ''
    hash = xml.is_a?(Hash) ? xml : Hash.from_xml(xml)
    raise Caren::Exceptions::InvalidXmlResponse unless hash
    if hash.has_key?(self.array_root.to_s)
      return hash[self.array_root.to_s].map{ |h| init_dependent_objects(self.from_xml(h)) }
    elsif hash.has_key?(self.node_root.to_s)
      return init_dependent_objects(self.new( hash[self.node_root.to_s], xml ))
    else
      return init_dependent_objects(self.new( hash, xml ))
    end
  end

  # Convert this object to XML
  def to_xml options={}
    self.as_xml.to_xml(options.merge( :root => (self.node_root || self.class.node_root) ))
  end

  # Overridable hash of attributes that is used for converting to XML.
  def as_xml
    attributes.reject{ |k,v| k == :action }
  end

  # The absolute (constructed url) to the resource.
  def self.resource_url id=nil
    [self.resource_location,id].compact.join("/")
  end

  def self.search_url key, value
    "#{self.resource_url}?key=#{key.to_s.dasherize}&value=#{value}"
  end

  # The absolute (constructed url) to the resource.
  def resource_url id=nil
    self.class.resource_url(id)
  end

  def self.hash_from_image hash_or_path
    return hash_or_path if hash_or_path.is_a?(Hash)
    { :name => File.basename(hash_or_path),
      :content => File.open(hash_or_path).read,
      :content_type => `file -b --mime-type #{hash_or_path}`.gsub(/\n/,"").split(";")[0] }
  end

  private

  # Method missing calls to enable getters/setters
  def method_missing args, value=nil
    return self.attributes[args] if self.class.keys.include?(args)
    return self.attributes[args.to_s.gsub('=','').to_sym] = value if self.class.keys.include?(args.to_s.gsub('=','').to_sym)
    super
  end

end
