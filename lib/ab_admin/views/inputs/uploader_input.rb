module AbAdmin
  module Views
    module Inputs
      class UploaderInput < ::SimpleForm::Inputs::Base
        disable :label, :wrapper#, :required

        def initialize(*args, &block)
          super
          @block = block

          @assoc = object.class.reflect_on_association(attribute_name)
          raise("Missing association #{attribute_name}") unless @assoc
          @uploader_options = {element_id: object.fileupload_guid}
          @render_options = {container: 'container'}
        end

        def input
          title = options[:title] || object.class.han(attribute_name)
          locals = {uploader_options: @uploader_options, uploader_js: uploader_js}
          template.capture do
            template.input_set(title) do
              template.render(partial: "admin/fileupload/#{@render_options[:container]}", locals: locals)
            end
          end
        end

        def uploader_assets
          if options.key?(:value)
            options.delete(:value)
          else
            object.fileupload_asset(attribute_name)
          end
        end

        def uploader_js
          template.init_js("new AdminAssets(#{js_options.to_json})")
        end

        def js_options
          {
            element_id: @uploader_options[:element_id],
            sort_url: template.sort_admin_assets_path(klass: @assoc.klass),
            alloved_extensions: @assoc.klass.ext_list,
            fileupload: {
              url: AbAdmin.fileupload_url,
              maxFileSize: (options[:file_max_size] || @assoc.klass.try(:max_size)).megabytes.to_i,
              formData: {
                assetable_type: 'User',
                assetable_id: 1,
                method: 'avatar'
              }
            }
          }
        end


        def attach_file_field(attribute_name, options = {})
          value = options.delete(:value) if options.key?(:value)
          value ||= object.fileupload_asset(attribute_name)
          asset_klass = object.reflections[attribute_name].try(:klass)

          element_guid = object.fileupload_guid
          element_id = template.dom_id(object, [attribute_name, element_guid].join('_'))
          max_size = options[:file_max_size] || asset_klass.try(:max_size)
          script_options = (options.delete(:script) || {}).stringify_keys

          params = {
              method: attribute_name,
              assetable_id: object.new_record? ? nil : object.id,
              assetable_type: object.class.name,
              guid: element_guid
          }.merge(script_options.delete(:params) || {})

          script_options['action'] ||= "#{AbAdmin.fileupload_url}?#{Rack::Utils.build_query(params)}"
          if !script_options['allowedExtensions'] && asset_klass
            script_options['allowedExtensions'] = asset_klass.ext_list
          end
          if options[:template_id]
            script_options['template_id'] = options[:template_id]
          end
          if options[:file]
            script_options['allowedExtensions'] ||= %w(pdf doc docx xls xlsx ppt pptx zip rar csv jpg jpeg gif png)
            script_options['template_id'] = '#fileupload_ftmpl'
            options[:asset_template] = 'file'
          elsif options[:video]
            script_options['allowedExtensions'] ||= %w(mp4 flv)
            script_options['template_id'] = '#fileupload_vtmpl'
            options[:asset_template] = 'video'
          end
          script_options['allowedExtensions'] ||= %w(jpg jpeg png gif)
          script_options['multiple'] ||= object.fileupload_multiple?(attribute_name)
          script_options['element'] ||= element_id
          script_options['sizeLimit'] = max_size.megabytes.to_i

          locals = {
              element_id: element_id,
              error: error(attribute_name),
              file_title: (options[:file_title] || script_options['allowedExtensions'].join(', ')),
              file_max_size: max_size,
              assets: [value].flatten.delete_if { |v| v.nil? || v.new_record? },
              button_title: options[:button_title] || I18n.t("admin.fileupload.button#{'s' if script_options['multiple']}"),
              asset_template: (options[:asset_template] || 'asset'),
              container_data: {
                  klass: params[:assetable_type],
                  asset: asset_klass.to_s,
                  assoc: params[:method],
                  multiple: script_options['multiple'],
                  crop: options[:crop],
                  edit_meta: options[:edit_meta]
              }
          }

          locals[:css_class] = ['fileupload', "#{locals[:asset_template]}_render_template"]
          locals[:css_class] << "#{options[:file] ? 'file' : 'image'}_asset_type"
          locals[:css_class] << (script_options['multiple'] ? 'many_assets' : 'one_asset')
          locals[:css_class] << 'error' if locals[:error]


          js_opts = [locals[:element_id], template.sort_admin_assets_path(klass: asset_klass), script_options['multiple']].map(&:inspect).join(', ')
          locals[:js] = <<-JAVASCRIPT
          var upl = new qq.FileUploaderInput(#{script_options.to_json});
          upl._setupDragDrop();
          new AdminAssets(#{js_opts});
          JAVASCRIPT

          if options[:description]
            opts = [attribute_name, object.class.name, object.id, object.fileupload_guid].map { |i| i.to_s.inspect }.join(', ')
            template.concat javascript_tag("$(function(){new AssetDescription(#{opts})})")
          end

          template.render(partial: "admin/fileupload/#{options[:container] || 'container'}", locals: locals)
        end

      end
    end
  end
end