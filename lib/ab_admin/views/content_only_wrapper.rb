module AbAdmin
  module Views
    class ContentOnlyWrapper < ::SimpleForm::Wrappers::Many
      include Singleton

      def initialize
      end

      def render(input)
        input.input
      end
    end
  end
end
