module AbAdmin
  class AbstractResource
    unloadable

    include Singleton

    ACTIONS = [:index, :show, :new, :edit, :create, :update, :destroy, :batch, :rebuild] unless self.const_defined?(:ACTIONS)

    attr_accessor :table, :search, :export, :form, :preview_path, :actions

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

      def preview_path(value=nil, &block)
        instance.preview_path = block_given? ? block : value
      end

      def actions(*actions_to_keep)
        instance.actions = begin
          options = actions_to_keep.extract_options!
          if options[:except]
            ACTIONS - Array(options[:except]).map(&:to_sym)
          else
            actions_to_keep
          end
        end.map(&:to_sym)
      end
    end

    def allow_action?(action)
      return true unless actions
      actions.include?(action.to_sym)
    end

  end

end