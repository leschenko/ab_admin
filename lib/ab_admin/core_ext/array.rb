class Array
  def deep_merge_hashes
    self.inject({}) do |res, h|
      raise Exception.new("Not a hash #{h}") unless h.is_a?(Hash)
      h.deep_merge(res)
    end
  end

  def mean
    return 0 if size == 0
    inject(:+) / size
  end

  def without!(*values)
    ActiveSupport::Deprecation.warn('Array#without! is deprecated without replacement')
    values.flatten.each { |value| self.delete(value) }
    self
  end

  def contain?(other)
    (other - self).empty?
  end

  def intersect?(other)
    !(self & other).empty?
  end
end
