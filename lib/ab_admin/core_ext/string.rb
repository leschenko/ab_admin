class String
  # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html
  #LUCENE_ESCAPE_REGEX = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~|\?|:|\\|\/)/
  #LUCENE_ESCAPE_REGEX = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~|\?|:|\\|\s)/

  KEYBOARDS = {
      en: 'qwertyuiop[]asdfghjkl;\'zxcvbnm,./',
      ru: 'йцукенгшщзхъфывапролджэячсмитьбю/'
  }

  unless defined? LUCENE_ESCAPE_REGEX
    LUCENE_ESCAPE_REGEX = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|\^|"|~|\*|\?|:|\\|\/)/

    def lucene_escape
      self.gsub(LUCENE_ESCAPE_REGEX, "\\\\\\1")
    end
  end

  def capitalize_first
    self.mb_chars[0].capitalize + self.mb_chars[1..-1]
  end

  def is_int?
    self =~ /^[-+]?[0-9]+$/
  end

  def is_number?
    self =~ /^[-+]?[0-9]+(\.[0-9]+)?$/
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
    str.gsub!(/<br\/?>/, ' ')
    str.gsub!(/<\/?[^>]*>/, '')
    str.strip!
    str.gsub!('&nbsp;', ' ')
    str
  end

  def tr_lang(from=nil, to=nil)
    return '' if self.blank?

    unless from || to
      if KEYBOARDS[:en].index(self[0])
        from, to = :en, :ru
      elsif KEYBOARDS[:ru].index(self[0])
        from, to = :ru, :en
      else
        from, to = :en, :ru
      end
    end

    self.tr(KEYBOARDS[from], KEYBOARDS[to])
  end

  def count_words
    clean_text.scan(/(\p{Alnum}+([-'.]\p{Alnum}+)*)/u).size
  end

  def words_count
		frequencies = Hash.new(0)  
		downcase.scan(/(\w+([-'.]\w+)*)/) { |word, ignore| frequencies[word] += 1 }
		frequencies
	end
	
	def self.randomize(length = 8)
	  Array.new(length) { (rand(122-97) + 97).chr }.join
  end

  def clean_text
    coder = HTMLEntities.new
    coder.decode(self.no_html)
  end

  def mb_upcase
    mb_chars.upcase.to_s
  end

  def mb_downcase
    mb_chars.downcase.to_s
  end
end

unless ''.respond_to?(:each)
  String.class_eval do
    def each &block
      self.lines &block
    end
  end
end
