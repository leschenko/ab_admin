require 'configatron'

class Settings

  extend ActiveModel::Naming
  include Singleton

  attr_accessor :paths, :data

  def initialize
    @data = {}
    @paths = []
    @editable_path = Rails.root.join('config', 'settings', "#{Rails.env}.local.yml")
  end

  def find_paths
    @paths = [
        Rails.root.join('config', 'settings', 'settings.yml'),
        Rails.root.join('config', 'settings', "#{Rails.env}.yml"),
        @editable_path
    ].find_all { |path| File.exists?(path) }
  end

  def all
    @paths.each do |path|
      @data.deep_merge(YAML.load_file(path))
    end
  end

  def editable
    YAML.load_file(@editable_path) #rescue {}
  end

  def save(raw_config)
    conf = {}
    raw_config.each do |root_key, root_value|
      if root_value.is_a?(Hash)
        conf[root_key] ||= {}
        root_value.each do |key, value|
          conf[root_key][key] = case_value(value)
        end
      else
        conf[root_key] = case_value(root_value)
      end
    end
    File.open(@editable_path, 'w') { |file| file.write conf.to_yaml } and self.class.load
  end

  def case_value(value)
    if %w(true false 1 0).include?(value) || value.is_number?
      YAML::load(value)
    else
      value
    end
  end

  def self.load
    configatron.configure_from_hash instance.all
    configatron
  end
end

  #class << self
  #  def method_missing(method, *args)
  #    if self.respond_to?(method)
  #      super
  #    else
  #      method_name = method.to_s
  #
  #      #set a value for a variable
  #      if method_name =~ /=$/
  #        var_name = method_name.gsub('=', '')
  #        value = args.first
  #        self[var_name] = value
  #
  #        #retrieve a value
  #      else
  #        self[method_name]
  #      end
  #    end
  #  end
  #
  #  #retrieve all settings as a hash (optionally starting with a given namespace)
  #  def all(starting_with=nil)
  #    query = target_scoped
  #    query = query.where(["var LIKE ?", "#{starting_with}%"]) if starting_with
  #
  #    result = defaults.dup
  #
  #    query.all.each do |record|
  #      result[record.var] = record.value
  #    end
  #
  #    result.with_indifferent_access
  #  end
  #
  #  #get a setting value by [] notation
  #  def [](var_name)
  #    cache.fetch(cache_key(var_name), cache_options) do
  #      if (var = target(var_name)).present?
  #        var.value
  #      else
  #        defaults[var_name.to_s]
  #      end
  #    end
  #  end
  #
  #  #set a setting value by [] notation
  #  def []=(var_name, value)
  #    record = target_scoped.where(:var => var_name.to_s).first
  #    record ||= new(:var => var_name.to_s)
  #
  #    record.value = value
  #    record.save!
  #    cache.write(cache_key(var_name), value, cache_options)
  #    value
  #  end
  #
  #  def merge!(var_name, hash_value)
  #    raise ArgumentError unless hash_value.is_a?(Hash)
  #
  #    old_value = self[var_name] || {}
  #    raise TypeError, "Existing value is not a hash, can't merge!" unless old_value.is_a?(Hash)
  #
  #    new_value = old_value.merge(hash_value)
  #    self[var_name] = new_value if new_value != old_value
  #
  #    new_value
  #  end
  #
  #  def target(var_name)
  #    target_scoped.where(:var => var_name.to_s).first
  #  end
  #
  #  def target_scoped
  #    scoped.where(:target_id => target_id, :target_type => target_type)
  #  end
  #
  #  def target_id
  #    nil
  #  end
  #
  #  def target_type
  #    nil
  #  end
  #
  #  def update_attributes(attrs)
  #    attrs.each do |key, value|
  #      self[key] = value
  #    end
  #  end
  #
  #  def to_key
  #    ['settings']
  #  end
  #end
  #
  ##get the value field, YAML decoded
  #def value
  #  YAML::load(self[:value])
  #end
  #
  ##set the value field, YAML encoded
  #def value=(new_value)
  #  self[:value] = new_value.to_yaml
  #end

#end
