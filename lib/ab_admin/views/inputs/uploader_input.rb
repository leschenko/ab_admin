module AbAdmin
  module Views
    module Inputs
      class UploaderInput < ::SimpleForm::Inputs::Base
        disable :label

        def initialize(*args, &block)
          super
          @assoc = object.class.reflect_on_association(attribute_name)
          defaults = {
              file_type: 'image',
              container_id: "#{attribute_name}_#{object.fileupload_guid}",
              multiple: @assoc.collection?,
              max_size: @assoc.klass.try(:max_size),
              error: @builder.error(attribute_name)
          }
          @options.reverse_merge!(defaults)
          @options[:extensions] = @assoc.klass.ext_list if @assoc.klass.ext_list
          @options[:sortable] = @options[:multiple] unless @options.has_key?(:sortable)
          @options[:asset_template] ||= @options[:file_type]
          @options[:container_class] = container_class
        end

        def input(*)
          title = options[:title] || object.class.han(attribute_name) if options[:title] || !options.key?(:title)
          template.capture do
            if @options[:unwrapped]
              render_input
            else
              template.input_set(title) { render_input }
            end
          end
        end

        def render_input
          locals = {
              options: @options,
              js_options: js_options,
              assets: uploader_values,
              asset_template: "#{theme_path}/#{@options[:asset_template]}"
          }
          template.render(partial: "#{theme_path}/container", locals: locals)
        end

        def container_class
          classes = Array(@options[:container_class])
          classes << (@options[:multiple] ? 'fileupload-multiple' : 'fileupload-single')
          classes << "fileupload-klass-#{@assoc.klass.name}"
          classes << "fileupload-record-#{object.fileupload_guid}"
          classes << "fileupload-theme-#{@options[:theme]}" if @options[:theme]
          classes << "fileupload-file_type-#{@options[:file_type]}"
          classes << "fileupload-asset_template-#{@options[:asset_template]}"
          classes << 'fileupload-sortable' if @options[:sortable]
          classes << 'error' if @options[:error]
          classes
        end

        def theme_path
          [@options[:views_path] || 'admin/fileupload', @options[:theme]].compact.join('/')
        end

        def uploader_values
          if options.key?(:value)
            values = options.delete(:value)
          else
            values = object.fileupload_asset(attribute_name)
          end
          Array(values).delete_if { |v| v.nil? || v.new_record? }
        end

        def js_options
          {
            container_id: @options[:container_id],
            file_type: @options[:file_type],
            asset_template: @options[:asset_template],
            multiple: @options[:multiple],
            sort_url: template.sort_admin_assets_path(klass: @assoc.klass.name),
            extensions: @options[:extensions],
            klass: @assoc.klass.name,
            sortable: @options[:sortable],
            edit_meta: @options[:edit_meta],
            crop: @options[:crop],
            disabled: @options[:disabled],
            fileupload: {
              url: AbAdmin.fileupload_url,
              maxNumberOfFiles: @options[:max_files],
              maxFileSize: @options[:max_size].try(:megabytes),
              minFileSize: @options[:min_size].try(:megabytes),
              formData: {
                assetable_type: object.class.name,
                assetable_id: object.id,
                method: attribute_name,
                guid: object.fileupload_guid
              }
            }
          }
        end

      end
    end
  end
end