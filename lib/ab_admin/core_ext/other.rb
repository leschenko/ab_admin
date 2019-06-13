class TrueClass
  def to_i
    1
  end
end

class FalseClass
  def to_i
    0
  end
end

class Object
  def to_bool
    ![false, 'false', '0', 0, 'f', nil, ''].include?(self.respond_to?(:downcase) ? self.downcase : self)
  end
end

class Date
  def tomorrow?
    self.to_date == ::Date.tomorrow
  end
end
