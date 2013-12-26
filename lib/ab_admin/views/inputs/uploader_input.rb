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
              extensions: @assoc.klass.ext_list,
              max_size: @assoc.klass.try(:max_size),
              error: @builder.error(attribute_name)
          }
          @options.reverse_merge!(defaults)
          @options[:sortable] = @options[:multiple] unless @options.has_key?(:sortable)
          @options[:container_class] = container_class
        end

        def input
          title = options[:title] || object.class.han(attribute_name)
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
              asset_template: "#{theme_path}/#{@options[:file_type]}"
          }
          template.render(partial: "#{theme_path}/container", locals: locals)
        end

        def container_class
          classes = Array(@options[:container_class])
          classes << (@options[:multiple] ? 'fileupload-multiple' : 'fileupload-single')
          classes << "fileupload-#{@options[:file_type]}_file_type"
          classes << "fileupload-#{@options[:theme]}_theme" if @options[:theme]
          classes << 'fileupload-sortable' if @options[:sortable]
          classes << "fileupload-klass-#{@assoc.klass.name}"
          classes << "fileupload-record-#{object.fileupload_guid}"
          classes << 'error' if @options[:error]
          classes
        end

        def theme_path
          ['admin/fileupload', @options[:theme]].compact.join('/')
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
            multiple: @options[:multiple],
            sort_url: template.sort_admin_assets_path(klass: @assoc.klass.name),
            extensions: @options[:extensions],
            klass: @assoc.klass.name,
            edit_meta: @options[:edit_meta],
            crop: @options[:crop],
            fileupload: {
              url: AbAdmin.fileupload_url,
              maxFileSize: @options[:max_size].megabytes.to_i,
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