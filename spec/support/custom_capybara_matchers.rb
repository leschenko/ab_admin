#RSpec::Matchers.define :have_widget_elements_for do |widget|
#  match do |actual|
#    order_pattern = begin
#      lines = actual.collect { |line| line.gsub(/\s+/, ' ') }.collect(&:strip).reject(&:blank?)
#      pattern = lines.collect(&Regexp.method(:quote)).join('.*?')
#      Regexp.compile(pattern)
#    end
#    page.find('body').text.gsub(/\s+/, ' ') =~ order_pattern
#  end
#
#  failure_message_for_should do |actual|
#    "expected 2 but got '#{actual}'"
#  end
#
#  failure_message_for_should_not do |actual|
#    "expected something else then 2 but got '#{actual}'"
#  end
#end

#module CustomCapybaraMatchers
#  class HaveOrderedList
#
#    def matches?(actual)
#      @actual = wrap(actual)
#      @actual.text.gsub(/\s+/, ' ') =~ order_pattern
#    end
#
#    def order_pattern
#      lines = @actual.collect { |line| line.gsub(/\s+/, ' ') }.collect(&:strip).reject(&:blank?)
#      pattern = lines.collect(&Regexp.method(:quote)).join('.*?')
#      Regexp.compile(pattern)
#    end
#
#    def failure_message
#      "expected 2 but got '#{@actual}'"
#    end
#
#    def negative_failure_message
#      "expected something else then 2 but got '#{@actual}'"
#    end
#
#    def wrap(actual)
#      if actual.respond_to?("has_selector?")
#        actual
#      else
#        Capybara.string(actual.to_s)
#      end
#    end
#
#    def format(text)
#      text = Capybara::Helpers.normalize_whitespace(text) unless text.is_a? Regexp
#      text.inspect
#    end
#
#  end
#
#end

