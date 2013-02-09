module AbAdmin
  module Views
    module UrlForRoutes
      extend ActiveSupport::Concern

      included do
        protected

        def resource_path(rec=nil, options={})
          r = rec || resource
          options.reverse_merge!(:id => r.id, :action => :show)
          url_for options
        end

        def edit_resource_path(rec=nil, options={})
          r = rec || resource
          options.reverse_merge!(:id => r.id, :action => :edit)
          url_for options
        end

        def new_resource_path(options={})
          options.reverse_merge!(:action => :new)
          url_for options
        end

        def collection_path(options={})
          options.reverse_merge!(:action => :index)
          url_for options
        end
      end

    end
  end
end
