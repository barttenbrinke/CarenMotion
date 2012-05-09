# This is just so that the source file can be loaded.
module Caren
  module Api
    class Motion
      def initialize(app)        
        app.frameworks << 'Security' # For openSSL
        app.files += Dir.glob('./vendor/caren-api/lib/motion/*.rb')
        app.files += Dir.glob('./vendor/caren-api/lib/caren/caren.rb')
        app.files += Dir.glob('./vendor/caren-api/lib/caren/**.rb')
        
        app.libs << "/usr/lib/libcrypto.dylib"
      end
    end
  end
end

# require "active_support/core_ext/hash/conversions"
# require "active_support/core_ext/array/conversions"
# 
# require "builder"
# require "rest_client"
# require "rexml/document"
# require "base64"
