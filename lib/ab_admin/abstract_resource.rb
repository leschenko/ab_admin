module AbAdmin
  class AbstractResource
    unloadable

    include Singleton

    attr_accessor :table, :search

    class << self
      def table(options={}, &block)
        #raise AbAdmin::Config::Table.new(options, &block).to_yaml
        instance.table = AbAdmin::Config::Table.new(options, &block)
      end

      def search(options={}, &block)
        instance.search = AbAdmin::Config::Search.new(options, &block)
      end
    end

  end

end