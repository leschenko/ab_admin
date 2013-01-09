# -*- encoding : utf-8 -*-
class String
  #LUCENE_ESCAPE_REGEX = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~|\?|:|\\)/
  LUCENE_ESCAPE_REGEX = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~|\?|:|\\|\s)/

  def lucene_escape
    self.gsub(LUCENE_ESCAPE_REGEX, "\\\\\\1")
  end

  def capitalize_first
    self.mb_chars[0].capitalize + self.mb_chars[1..-1]
  end

  def is_int?
    self =~ /^[-+]?[0-9]*$/
  end

  def to_utc
    begin
      Time.zone.parse(self).utc
    rescue
      Time.now.utc
    end
  end

  def no_html
    str = self.dup
    str.gsub!(/<\/?[^>]*>/, '')
    str.strip!
    str.gsub!('&nbsp;', ' ')
    str
  end

  def tr_lang(from=nil, to=nil)
    return '' if self.blank?

    keyboard = {}
    keyboard[:en] = %{qwertyuiop[]asdfghjkl;'zxcvbnm,./}
    keyboard[:ru] = %{йцукенгшщзхъфывапролджэячсмитьбю/}

    unless from || to
      if keyboard[:en].index(self[0])
        from, to = :en, :ru
      elsif keyboard[:ru].index(self[0])
        from, to = :ru, :en
      else
        from, to = :en, :ru
      end
    end

    self.tr(keyboard[from], keyboard[to])
  end

  def words_count
		frequencies = Hash.new(0)  
		downcase.scan(/(\w+([-'.]\w+)*)/) { |word, ignore| frequencies[word] += 1 }
		return frequencies
	end
	
	def self.randomize(length = 8)
	  Array.new(length) { (rand(122-97) + 97).chr }.join
  end

end

if Object.const_defined?(:HTMLEntities)
  require 'htmlentities'
  class String
    def clean_text
      coder = HTMLEntities.new
      coder.decode(self.no_html)
    end
  end
else
  Rails.logger.warn 'Install gem \'htmlentities\' to use clean_text'
end

unless ''.respond_to?(:each)
  String.class_eval do
    def each &block
      self.lines &block
    end
  end
end
