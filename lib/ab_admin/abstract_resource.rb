module AbAdmin
  class AbstractResource
    unloadable

    include Singleton

    attr_accessor :table, :search, :export, :form

    class << self
      def table(options={}, &block)
        instance.table = AbAdmin::Config::Table.new(options, &block)
      end

      def search(options={}, &block)
        instance.search = AbAdmin::Config::Search.new(options, &block)
      end

      def export(options={}, &block)
        instance.export = ::AbAdmin::Config::Export.new(options, &block)
      end

      def form(options={}, &block)
        instance.form = ::AbAdmin::Config::Form.new(options, &block)
      end
    end

  end

end