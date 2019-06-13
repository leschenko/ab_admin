class String
  def no_html
    str = self.dup
    str.gsub!(/<br\/?>/, ' ')
    str.gsub!(/<\/?[^>]*>/, '')
    str.strip!
    str.gsub!('&nbsp;', ' ')
    str
  end
end

unless ''.respond_to?(:each)
  String.class_eval do
    def each &block
      self.lines &block
    end
  end
end
