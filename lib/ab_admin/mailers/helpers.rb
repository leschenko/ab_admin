module AbAdmin
  module Mailers
    module Helpers
      def i18n_scope
        [mailer_name, action_name]
      end
    end
  end
end