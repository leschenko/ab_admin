class NilClass
  def val(*args)
    self
  end
end

class Time
  def formatted_datetime
    I18n.l(self, :format => "%d.%m.%Y %H:%M")
  end

  def formatted_date
    I18n.l(self, :format => "%d.%m.%Y")
  end
end

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

#module ActiveSupport
#  class OrderedHash < ::Hash
#    def to_yaml(opts = {})
#      YAML::quick_emit(self, opts) do |out|
#        out.map(nil, to_yaml_style) do |map|
#          each do |k, v|
#            map.add(k, v)
#          end
#        end
#      end
#    end
#  end
#end

#class Numeric
#  # round a given number to the nearest step
#  def round_by(increment)
#    (self /increment).round * increment
#  end
#end
#
#class Float
#  def ceil_to(i=4)
#    #(self * 10**i).ceil.to_f / 10**i
#    (self * (10.0 ** i)).round(10).ceil * (10.0 ** (-i))
#  end
#
#  def floor_to(i=4)
#    (self * 10**i).floor.to_f / 10**i
#  end
#
#  def round_to
#    return (self+0.5).floor if self > 0.0
#    return (self-0.5).ceil if self < 0.0
#    0
#  end
#end