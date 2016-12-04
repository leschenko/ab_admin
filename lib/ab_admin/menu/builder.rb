module AbAdmin
  module Menu
    class Builder < AbstractBuilder
      include ::Singleton

      def self.draw(&block)
        I18n.with_locale AbAdmin.locale do
          instance.instance_eval &block if block_given?
        end
      end

      def self.render(*args)
        instance.render(*args)
      end
    end
  end
end
