module AbAdmin
  module Mailers
    class DevelopmentMailInterceptor
      def self.delivering_email(message)
        message.subject = "[#{message.to}] #{message.subject}"
        message.to = 'leschenko.al@gmail.com'
      end
    end
  end
end

