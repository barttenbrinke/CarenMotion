class Base64
  def self.encode64(string)
    NSData.alloc.initWithData(string).base64EncodedString
  end
end