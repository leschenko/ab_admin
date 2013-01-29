# -*- encoding : utf-8 -*-
require 'simple_form'
require 'nested_form/builder_mixin'

module AbAdmin
  module Views
    class FormBuilder < ::SimpleForm::FormBuilder
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::TagHelper
      include NestedForm::BuilderMixin

      delegate :concat, :content_tag, :link_to, :link_to_function, :dom_id, :render, :to => :template

      map_type :color, :to => ::AbAdmin::Views::Inputs::ColorInput
      map_type :ckeditor, :to => ::AbAdmin::Views::Inputs::ColorInput
      map_type :editor, :to => ::AbAdmin::Views::Inputs::EditorInput
      map_type :tree_select, :to => ::AbAdmin::Views::Inputs::TreeSelectInput

      def input(attribute_name, options = {}, &block)
        #options[:input_html] ||= {}
        #case options[:as]
          #when :text
          #  options[:input_html].reverse_merge!({:size => '40x3'})
          #when :ckeditor
          #  unless template.instance_variable_get(:@ckeditor_init)
          #    #concat template.javascript_include_tag("/assets/ckeditor/init")
          #    concat template.javascript_include_tag("/javascripts/ckeditor/init")
          #    template.instance_variable_set(:@ckeditor_init, true)
          #  end
          #  options[:input_html].reverse_merge!({:width => 800, :height => 200, :toolbar => 'Easy'})
          #when :editor
          #  options[:input_html] ||= {}
          #  options[:input_html][:class] = "#{options[:input_html][:class]} do_wysihtml5"
          #  options[:as] = :text
          #when :tree_select
          #  options[:collection] ||= @template.nested_set_options(object.class) { |i| "#{'–' * i.depth} #{i.title}" }.delete_if { |i| i[1] == object.id }
          #  options[:as] = :select
        #end
        attribute_name = "#{attribute_name}_#{options[:locale]}" unless options[:locale].blank?

        super(attribute_name, options, &block)
      end

      def locale_tabs(options={}, &block)
        loc_html = {}
        Globalize.available_locales.each do |l|
          loc_html[l] = template.capture { block.call(l) }
        end
        template.render 'admin/shared/locale_tabs', :loc_html => loc_html
      end

      def save_buttons
        template.render 'admin/shared/save_buttons'
      end

      def attach_file_field(attribute_name, options = {}, &block)
        value = options.delete(:value) if options.key?(:value)
        value ||= object.fileupload_asset(attribute_name)

        element_guid = object.fileupload_guid
        element_id = dom_id(object, [attribute_name, element_guid].join('_'))
        max_size = options[:file_max_size] || object.class.max_size
        script_options = (options.delete(:script) || {}).stringify_keys

        params = {
            :method => attribute_name,
            :assetable_id => object.new_record? ? nil : object.id,
            :assetable_type => object.class.name,
            :guid => element_guid
        }.merge(script_options.delete(:params) || {})

        script_options['action'] ||= '/sunrise/fileupload?' + Rack::Utils.build_query(params)
        if !script_options['allowedExtensions'] && object.reflections[attribute_name]
          script_options['allowedExtensions'] = object.reflections[attribute_name].klass.ext_list
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
