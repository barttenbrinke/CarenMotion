# This class provides a wrapper for caren's server side errors.
class Caren::Error

  attr_accessor :category, :message, :attributes

  def initialize category, message="", attributes={}
    self.category = category
    self.message = message
    self.attributes = attributes
  end

end

class Caren::UnauthorizedError < Caren::Error
end

class Caren::NotFoundError < Caren::Error
end

class Caren::BadRequestError < Caren::Error
end

class Caren::NotAcceptableError < Caren::Error
end

class Caren::MethodNotAllowedError < Caren::Error
end

class Caren::ValidationError < Caren::NotAcceptableError

  def field
    attributes[:on]
  end

  def to_s
    "`#{field}` #{message}"
  end

end
