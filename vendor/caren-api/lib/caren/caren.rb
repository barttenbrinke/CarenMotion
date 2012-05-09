module Caren

  module Exceptions

    class StandardError < ::StandardError ; end

    class SignatureMismatch < Caren::Exceptions::StandardError ; end

    class InvalidXmlResponse < Caren::Exceptions::StandardError ; end

    class ServerSideError < Caren::Exceptions::StandardError

      attr_accessor :errors, :http_code

      def initialize errors=[], http_code=nil
        self.errors = errors
        self.http_code = http_code
      end

    end

  end

  class Api

    class << self
      attr_accessor :session
    end

    # The user_agent is an optional identifier
    attr_accessor :url, :caren_public_key, :private_key, :user_agent

    # Initialize new API session. Specify your private key to sign outgoing messages and your care provider url.
    # Optionally you can pass the caren public key used to verify incoming requests.
    def initialize private_key, url, caren_public_key=nil
      self.url = url
      self.private_key = private_key.is_a?(String) ? Caren::Api.key_from_string(private_key) : private_key
      self.caren_public_key = caren_public_key || Caren::Api.key_from_path("#{File.dirname(__FILE__)}/../../certs/caren-api.pub")
    end

    # Create key from string
    def self.key_from_string string
      OpenSSL::PKey::RSA.new(string)
    end

    # Read a file and create key from string
    def self.key_from_path path
      self.key_from_string( File.read(path) )
    end

    # Generate a new private key
    def self.generate_private_key size=2048
      OpenSSL::PKey::RSA.generate( size )
    end

    # URL from path using session base url
    def url_for path
      "#{self.url}#{path}"
    end

    def put path, xml
      begin
        timestamp = DateTime.now.to_i
        response = RestClient.put url_for(path), xml, :content_type => :xml,
                                                      :accept => :xml,
                                                      :timestamp => timestamp,
                                                      :signature => sign(timestamp,path,xml),
                                                      :user_agent => user_agent
        return check_signature(response)
      rescue RestClient::Exception => e
        handle_error(e.response,e.http_code)
      end
    end

    def post path, xml
      begin
        timestamp = DateTime.now.to_i
        response = RestClient.post url_for(path), xml, :content_type => :xml,
                                                       :accept => :xml,
                                                       :timestamp => timestamp,
                                                       :signature => sign(timestamp,path,xml),
                                                       :user_agent => user_agent
        return check_signature(response)
      rescue RestClient::Exception => e
        handle_error(e.response,e.http_code)
      end
    end

    def delete path
      begin
        timestamp = DateTime.now.to_i
        response = RestClient.delete url_for(path), :content_type => :xml,
                                                    :accept => :xml,
                                                    :timestamp => timestamp,
                                                    :signature => sign(timestamp,path),
                                                    :user_agent => user_agent
        return check_signature(response)
      rescue RestClient::Exception => e
        handle_error(e.response,e.http_code)
      end
    end

    def get path
      begin
        timestamp = DateTime.now.to_i
        response = RestClient.get url_for(path), :content_type => :xml,
                                                 :accept => :xml,
                                                 :timestamp => timestamp,
                                                 :signature => sign(timestamp,path),
                                                 :user_agent => user_agent
        return check_signature(response)
      rescue RestClient::Exception => e
        handle_error(e.response,e.http_code)
      end
    end

    # These types of Caren objects are supported by the Caren::Api.incoming method
    def self.supported_incoming_objects
      { :links => Caren::Link,
        :external_messages => Caren::ExternalMessage,
        :care_providers => Caren::CareProvider,
        :billable_categories => Caren::Store::BillableCategory,
        :billables => Caren::Store::Billable,
        :invoices => Caren::Store::Invoice,
        :payments => Caren::Store::Payment,
        :line_items => Caren::Store::LineItem
      }
    end

    # These types of Caren objects are supported by the Caren::Api.incoming method
    def self.supported_incoming_single_objects
      singles = {}
      self.supported_incoming_objects.each do |object,klass|
        singles[ klass.node_root ] = klass
      end
      return singles
    end

    # Pass an XML string to be handled. Only a valid caren_objects xml hash will be parsed.
    def incoming xml, signature, timestamp
      if self.verify_signature(signature,timestamp, xml)
       return parse(xml)
      else
        raise Caren::Exceptions::SignatureMismatch.new
      end
    end

    def parse xml
      objects = []
      hash   = Hash.from_xml(xml)
      if hash["caren_objects"]
        hash = hash["caren_objects"]
      end
      Caren::Api.supported_incoming_objects.each do |key,klass|
        objects << (hash[key]||hash[key.to_s]||[]).map{ |h| klass.init_dependent_objects(klass.new(h,xml)) }
      end
      return objects.flatten
    end

    def parse_object xml
      hash = Hash.from_xml(xml)
      #todo: rewrite so we lookup the xml tag in the supported_incoming_single_objects hash, faster :)
      Caren::Api.supported_incoming_single_objects.each do |key, klass|
        object = hash[key] || hash[key.to_s]
        if object
          return klass.init_dependent_objects(klass.new(object,xml))
        end
      end
    end

    # Sign your string and timestamp using private key
    # Timestamp is UNIX timestamp seconds since 1970
    def sign timestamp, path=nil, string=nil, private_key=self.private_key
      path = URI.parse(path).path if path
      encrypted_digest = private_key.sign( OpenSSL::Digest::SHA1.new, "#{path}#{string}#{timestamp}".strip )
      signature = CGI.escape(Base64.encode64(encrypted_digest))
      return signature
    end

    # Check the signature of the response from rest-client
    def check_signature response
      return response if self.verify_signature( response.headers[:signature], response.headers[:timestamp], nil, response )
      raise Caren::Exceptions::SignatureMismatch.new
    end

    # Verify the signature using the caren public key
    def verify_signature signature, timestamp, path, string=nil, public_key=self.caren_public_key
      return false unless public_key
      signature = Base64.decode64(CGI.unescape(signature.to_s))
      public_key.verify( OpenSSL::Digest::SHA1.new, signature, "#{path}#{string}#{timestamp}".strip )
    end

    def create_photo_signature url_shortcut, external_or_caren_id, private_key=self.private_key
      digest = OpenSSL::PKey::RSA.new(private_key).sign( OpenSSL::Digest::SHA1.new, url_shortcut.to_s + external_or_caren_id.to_s )
      return CGI.escape(Base64.encode64(digest))
    end

    # Verify photo url signature using the caren public key
    def verify_photo_signature signature, url_shortcut, external_id, public_key=self.caren_public_key
      return false unless public_key
      signature = Base64.decode64(CGI.unescape(signature.to_s))
      public_key.verify( OpenSSL::Digest::SHA1.new, signature, url_shortcut.to_s + external_id.to_s )
    end

    private

    # Raise a Caren exception on errors
    def handle_error response, http_code
      errors = []
      doc = REXML::Document.new(response)
      doc.elements.each('errors/error') do |error|
        if error.attributes["category"] == "validation"
          attrs  = { :on => error.attributes["on"].to_s.underscore.to_sym }
          errors << Caren::ValidationError.new( error.attributes["category"], error.text.strip, attrs )
        else
          case http_code
          when 400
            errors << Caren::BadRequestError.new( error.attributes["category"], error.text.strip )
          when 401
            errors << Caren::UnauthorizedError.new( error.attributes["category"], error.text.strip )
          when 404
            errors << Caren::NotFoundError.new( error.attributes["category"], error.text.strip )
          when 405
            errors << Caren::MethodNotAllowedError.new( error.attributes["category"], error.text.strip )
          when 406
            errors << Caren::NotAcceptableError.new( error.attributes["category"], error.text.strip )
          else
            errors << Caren::Error.new( error.attributes["category"], error.text.strip )
          end
        end
      end
      raise Caren::Exceptions::ServerSideError.new(errors,http_code)
    end

  end

end
