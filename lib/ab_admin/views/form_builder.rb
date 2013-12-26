require 'simple_form'
require 'nested_form/builder_mixin'

module AbAdmin
  module Views
    class FormBuilder < ::SimpleForm::FormBuilder
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::TagHelper
      include NestedForm::BuilderMixin if defined? NestedForm

      map_type :color, to: ::AbAdmin::Views::Inputs::ColorInput
      map_type :ckeditor, to: ::AbAdmin::Views::Inputs::CkeditorInput
      map_type :editor, to: ::AbAdmin::Views::Inputs::EditorInput
      map_type :date_picker, :time_picker, :datetime_picker, to: ::AbAdmin::Views::Inputs::DateTimePickerInput
      map_type :token, to: ::AbAdmin::Views::Inputs::TokenInput
      map_type :capture_block, to: ::AbAdmin::Views::Inputs::CaptureBlockInput
      map_type :uploader, to: ::AbAdmin::Views::Inputs::UploaderInput

      def input(attribute_name, options = {}, &block)
        options[:collection] = options[:collection].call if options[:collection].is_a?(Proc)
        if options[:fancy] || (options[:collection] && options[:collection].to_a.length > 30)
          options[:input_html] ||= {}
          options[:input_html][:class] = "#{options[:input_html][:class]} fancy_select"
        end

        if options[:append]
          return super(attribute_name, options.merge(wrapper: 'append')) do
            input_field(attribute_name, options.merge(options[:input_html] || {})) + %(<span class="add-on #{options[:append_class]}">#{options[:append]}</span>).html_safe
          end
        end

        case options[:as]
          when :map
            title = options[:title] || I18n.t("admin.#{attribute_name}", default: object.class.han(attribute_name))
            prefix = options[:prefix] || object.class.model_name.singular
            data_fields = [:lat, :lon, :zoom].map { |attr| hidden_field(attr) }.join.html_safe
            return template.input_set(title) { data_fields + geo_input(prefix, options[:js_options]) }
          when :token
            options[:label] ||= object.class.han(attribute_name.to_s.sub(/^token_|_id$/, ''))
          when :association, :tree_select
            unless options[:reflection]
              if options[:as] == :tree_select
                options[:collection] ||= begin
                  reflection = object.class.reflect_on_association(attribute_name)
                  records = reflection.klass.all(reflection.options.slice(:conditions, :order))
                  reflection.klass.nested_opts_with_parent(records, object)
                end
              end
              return association(attribute_name, options.merge(as: :select))
            end
          when :checkbox_tree
            reflection = object.class.reflect_on_association(attribute_name)
            return template.render 'admin/shared/inputs/checkbox_tree', attribute_name: attribute_name, reflection: reflection, f: self
        end

        attribute_name = "#{attribute_name}_#{options[:locale]}" if options[:locale]

        super(attribute_name, options, &block)
      end

      def render_dsl_node(node, options={})
        input node.name, node.options.merge(options), &node.block
      end

      def link_to_add_assoc(assoc, options={})
        model = @object.class.reflect_on_association(assoc).klass
        title = [@template.icon('plus', true), I18n.t('admin.add'), options[:title] || model.model_name.human].join(' ').html_safe
        link_to_add title, assoc, class: "btn btn-primary #{options[:class]}"
      end

      def link_to_remove_assoc
        link_to_remove @template.icon('trash', true) + I18n.t('admin.delete'), class: 'btn btn-danger btn-mini pull-right'
      end

      def locale_tabs(&block)
        loc_html = {}
        Globalize.available_locales.each do |l|
          loc_html[l] = template.capture { block.call(l) }
        end
        template.render 'admin/shared/locale_tabs', loc_html: loc_html
      end

      def save_buttons
        template.render 'admin/shared/save_buttons'
      end

      def geo_input(prefix, js_options={}, &block)
        input_name = "#{prefix}_geo_ac"
        js = %Q[$("##{prefix}_geo_input").geoInput(#{js_options.to_json})]
        <<-HTML.html_safe
        <script src="//maps.googleapis.com/maps/api/js?sensor=false&libraries=places&language=#{I18n.locale}" type="text/javascript"></script>
        <div class="geo_input" id="#{prefix}_geo_input">
          <div class="control-group">
            <label class="control-label" for="#{input_name}">#{I18n.t('admin.geo_autocomplete')}</label>
            <div class="controls">
              <input type="text" name="#{input_name}" id="#{input_name}" class="geo_ac string">
            </div>
          </div>
          #{template.capture(&block) if block_given?}
          <div class="controls"><div id="#{prefix}_map" class="admin_map thumbnail"></div></div>
        </div>
        #{template.init_js(js)}
        HTML
      end

      protected

      def object_plural
        object_name.to_s.pluralize
      end
    end
  end
end
