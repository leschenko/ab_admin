module AbAdmin
  module Controllers
    module Fv
      extend ActiveSupport::Concern

      included do
        attr_writer :fv
        helper_method :fv
      end

      def fv
        @fv ||= OpenStruct.new
      end
    end
  end
end