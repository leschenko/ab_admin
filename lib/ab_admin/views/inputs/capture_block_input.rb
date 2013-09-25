module AbAdmin
  module Views
    module Inputs
      class CaptureBlockInput < ::SimpleForm::Inputs::Base
        def initialize(*args, &block)
          super
          @block = block
        end

        def input
          template.capture(@builder, &@block)
        end
      end
    end
  end
end