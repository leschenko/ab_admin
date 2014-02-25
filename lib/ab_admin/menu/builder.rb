module AbAdmin
  module Menu
    class Builder < AbstractBuilder
      include ::Singleton

      def self.draw(&block)
        I18n.locale = AbAdmin.locale if AbAdmin.locale
        instance.instance_eval &block if block_given?
      end

      def self.render(*args)
        instance.render(*args)
      end
    end
  end
end
