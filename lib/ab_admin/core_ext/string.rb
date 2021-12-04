class String
  def no_html
    self.dup.gsub(/<br\/?>/, ' ').gsub(/<\/?[^>]*>/, '').strip.gsub('&nbsp;', ' ').gsub('&gt;', '>').gsub('&lt;', '<')
  end
end

unless ''.respond_to?(:each)
  String.class_eval do
    def each &block
      self.lines &block
    end
  end
end
