class Hash

  def reverse_deep_merge!(other_hash)
    other_hash.each_pair do |k, v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? v.deep_merge!(tv) : (self[k] || v)
    end
    self
  end

  def deep_clear_values
    self.each_key do |key|
      if self[key].is_a?(Hash)
        self[key] = self[key].deep_clear_values
      else
        self[key] = ''
      end
    end
    self
  end

  def clear_values
    result = {}
    self.each_key do |key|
      result[key] = ''
    end
    result
  end

  def deep_diff(b)
    a = self
    (a.keys | b.keys).inject({}) do |diff, k|
      if a[k] != b[k]
        if a[k].respond_to?(:deep_diff) && b[k].respond_to?(:deep_diff)
          diff[k] = a[k].deep_diff(b[k])
        else
          diff[k] = [a[k], b[k]]
        end
      end
      diff
    end
  end

  def deep_add(other_hash)
    other_hash.each_pair do |k, v|
      tv = self[k]
      if self[k]
        self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_add(v) : v
      end
    end
    self
  end

  def add(other_hash)
    other_hash.each_pair do |k, v|
      self[k] = v if self.keys.include?(k)
    end
  end

  def val(*array)
    if array.empty?
      self
    else
      key = array.shift
      value = self[key]
      if array.empty?
        value
      elsif value.is_a? Hash
        value.val(*array)
      else
        nil
      end
    end
  end

  def store_multi(value, *keys)
    key = keys.shift
    self[key] ||= {}
    if keys.empty?
      self[key] = value
    else
      self[key] = self[key].store_multi(value, *keys)
    end
    self
  end

  def downcase_keys
    new_hash = {}
    self.each do |k, v|
      new_hash[k.to_s.downcase] = v
    end
    new_hash
  end

  def no_blank
    reject { |_, v| v.blank? }
  end

  def try_keys(*try_keys)
    try_keys.each do |k|
      return self[k] if self.has_key?(k)
    end
    default
  end

  def deep_stringify_keys
    inject({}) { |result, (key, value)|
      value = value.deep_stringify_keys if value.is_a?(Hash)
      result[(key.to_s rescue key) || key] = value
      result
    }
  end unless Hash.method_defined?(:deep_stringify_keys)

end
