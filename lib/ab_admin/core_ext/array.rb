class Array
  # TOREMOVE after ruby 2.7.0
  def tally
    each_with_object(Hash.new(0)) { |v, h| h[v] += 1 }
  end

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

  def without(*values)
    copy = self.dup
    copy.without!(*values)
  end

  def without!(*values)
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
