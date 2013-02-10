require 'simple_form'
require 'nested_form/builder_mixin'

module AbAdmin
  module Views
    class FormBuilder < ::SimpleForm::FormBuilder
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::TagHelper
      include NestedForm::BuilderMixin

      map_type :color, :to => ::AbAdmin::Views::Inputs::ColorInput
      map_type :ckeditor, :to => ::AbAdmin::Views::Inputs::CkeditorInput
      map_type :editor, :to => ::AbAdmin::Views::Inputs::EditorInput
      map_type :tree_select, :to => ::AbAdmin::Views::Inputs::TreeSelectInput
      map_type :association, :to => ::AbAdmin::Views::Inputs::AssociationInput
      map_type :date, :time, :datetime, :to => ::AbAdmin::Views::Inputs::DateTimeInput

      def input(attribute_name, options = {}, &block)
        if options[:fancy]
          options[:input_html] ||= {}
          options[:input_html][:class] = "#{options[:input_html][:class]} do_chosen"
        end

        case options[:as]
          when :uploader
            title = options[:title] || I18n.t("admin.#{attribute_name}", :default => object.class.han(attribute_name))
            return template.input_set(title) { attach_file_field(attribute_name, options = {}) }
          when :map
            title = options[:title] || I18n.t("admin.#{attribute_name}", :default => object.class.han(attribute_name))
            prefix = options[:prefix] || object.class.model_name.singular
            data_fields = [:lat, :lon, :zoom].map { |attr| hidden_field(attr) }.join.html_safe
            return template.input_set(title) { data_fields + geo_input(prefix) }
        end

        attribute_name = "#{attribute_name}_#{options[:locale]}" if options[:locale]

        super(attribute_name, options, &block)
      end

      def link_to_add_assoc(assoc, options={})
        model = @object.class.reflect_on_association(assoc).klass
        title = [@template.icon('plus', true), I18n.t('admin.add'), model.model_name.human].join(' ').html_safe
        link_to_add title, assoc, :class => "btn btn-primary #{options[:class]}"
      end

      def link_to_remove_assoc
        link_to_remove @template.icon('trash', true) + I18n.t('admin.delete'), :class => 'btn btn-danger btn-mini pull-right'
      end

      def locale_tabs(&block)
        loc_html = {}
        Globalize.available_locales.each do |l|
          loc_html[l] = template.capture { block.call(l) }
        end
        template.render 'admin/shared/locale_tabs', :loc_html => loc_html
      end

      def save_buttons
        template.render 'admin/shared/save_buttons'
      end

      def geo_input(prefix, &block)
        template.content_tag :div, :class => 'geo_input' do
          ''.tap do |out|
            out << template.javascript_include_tag("//maps.googleapis.com/maps/api/js?sensor=false&libraries=places&language=#{I18n.locale}")
            out << template.label_tag(:geo_autocomplete, I18n.t('admin.geo_autocomplete'))
            out << template.text_field_tag("#{prefix}_geo_autocomplete")
            out.concat(capture(&block)) if block_given?
            out << template.content_tag(:div, '', :class => 'admin_map', :id => "#{prefix}_map")
            out << template.init_js("initGeoInput(#{prefix.inspect})")
          end.html_safe
        end
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
            :method => attribute_name,
            :assetable_id => object.new_record? ? nil : object.id,
            :assetable_type => object.class.name,
            :guid => element_guid
        }.merge(script_options.delete(:params) || {})

        script_options['action'] ||= '/sunrise/fileupload?' + Rack::Utils.build_query(params)
        if !script_options['allowedExtensions'] && asset_klass
          script_options['allowedExtensions'] = asset_klass.ext_list
        end
        if options[:template_id]
          script_options['template_id'] = options[:template_id]
        end
        if options[:file]
          script_options['allowedExtensions'] ||= %w(pdf doc docx xls xlsx ppt pptx zip rar csv jpg jpeg gif png)
          script_options['template_id'] = '#fileupload_ftmpl'
          options[:asset_render_template] = 'file'
        end
        if options[:video]
          script_options['allowedExtensions'] ||= %w(mp4 flv)
          script_options['template_id'] = '#fileupload_vtmpl'
          options[:asset_render_template] = 'video_file'
        end
        script_options['allowedExtensions'] ||= %w(jpg jpeg png gif)
        script_options['multiple'] ||= object.fileupload_multiple?(attribute_name)
        script_options['element'] ||= element_id
        script_options['sizeLimit'] = max_size.megabytes.to_i

        label ||= if object && object.class.respond_to?(:human_attribute_name)
                    object.class.human_attribute_name(attribute_name)
                  end

        locals = {
            :element_id => element_id,
            :file_title => (options[:file_title] || "JPEG, GIF, PNG or TIFF"),
            :file_max_size => max_size,
            :label => (label || attribute_name.to_s.humanize),
            :object => object,
            :attribute_name => attribute_name,
            :assets => [value].flatten.delete_if { |v| v.nil? || v.new_record? },
            :script_options => script_options.inspect.gsub('=>', ':'),
            :multiple => script_options['multiple'],
            :asset_klass => params[:klass],
            :asset_render_template => (options[:asset_render_template] || 'asset'),
            :container_data => {klass: params[:assetable_type], assoc: params[:method], multiple: script_options['multiple']}
        }

        if options[:file1]
          container_tmpl = 'fcontainer'
        elsif options[:container]
          container_tmpl = options[:container]
        else
          container_tmpl = 'container'
        end

        if options[:description]
          opts = [attribute_name, object.class.name, object.id, object.fileupload_guid].map { |i| i.to_s.inspect }.join(', ')
          template.concat javascript_tag("$(function(){new AssetDescription(#{opts})})")
        end

        template.render(:partial => "admin/fileupload/#{container_tmpl}", :locals => locals)
      end

      protected

      def object_plural
        object_name.to_s.pluralize
      end
    end
  end
end
