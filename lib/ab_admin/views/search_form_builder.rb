module AbAdmin
  module Views
    class SearchFormBuilder < ::Ransack::Helpers::FormBuilder
      delegate :content_tag, :tag, :params,
               :text_field_tag, :check_box_tag, :radio_button_tag, :label_tag, :select_tag,
               :options_for_select, :options_from_collection_for_select, :hidden_field_tag, to: :@template

      alias_method :builder_options, :options

      def input(attr, options={})
        field_type = field_type(attr, options)
        options[:wrapper_html] ||= {}
        options[:wrapper_html][:class] = "clearfix #{field_type} #{options[:wrapper_html][:class]}"
        content_tag :div, options[:wrapper_html] do
          public_send("#{field_type}_field", attr, options)
        end
      end

      def select_field(attr, options={})
        conditional_wrapper attr, options do
          param = options[:param] || "#{options[:value_attr] || attr}_eq"

          if options[:collection].is_a?(Proc)
            collection = options[:collection].call
          else
            collection = options[:collection] || []
          end

          if collection.first.try(:respond_to?, :id)
            collection = collection.map{|r| [AbAdmin.display_name(r), r.id] }
          end

          options[:input_html] ||= {}

          if options[:fancy] || collection.length > 30
            options[:input_html][:class] = [options[:input_html][:class], 'fancy_select'].join(' ')
          end

          if options[:input_html][:placeholder]
            options[:input_html][:include_blank] = false
            options[:input_html][:prompt] ||= options[:input_html][:placeholder]
          else
            options[:input_html][:include_blank] = true
          end
          select_tag("q[#{param}]", options_for_select(collection, params[:q][param]), options[:input_html])
        end
      end

      def ac_select_field(attr, options={})
        klass = options[:klass]
        options[:param] ||= "#{options[:value_attr] || attr}_eq"
        pre_select = params[:q].try!(:[], options[:param]) ? klass.where(id: params[:q][options[:param]]).map(&:for_input_token) : []
        options[:input_html] ||= {}
        options[:input_html].deep_merge! class: 'fancy_select', data: {class: klass.name, pre: pre_select.to_json}
        string_field attr, options
      end

      def date_field(attr, options={})
        label(attr, options[:label]) + content_tag(:div, class: 'controls') do
          gt_param, lt_param = "#{attr}_gteq", "#{attr}_lteq"
          text_field_tag("q[#{gt_param}]", params[:q][gt_param], class: 'input-small datepicker', autocomplete: 'off') +
          text_field_tag("q[#{lt_param}]", params[:q][lt_param], class: 'input-small datepicker', autocomplete: 'off', id: "q_#{attr}")
        end
      end

      def conditional_wrapper(attr, options, &block)
        if builder_options[:compact_labels]
          options[:input_html] ||= {}
          options[:input_html][:placeholder] ||= extract_label(attr, options)
          wrapper_html = {'class' => 'controls tool tool-left', 'data-placement' => 'left', 'title' => options[:input_html][:placeholder]}
          content_tag(:div, wrapper_html, &block)
        else
          label(attr, options[:label]) + content_tag(:div, class: 'controls', &block)
        end
      end

      def string_field(attr, options={})
        conditional_wrapper attr, options do
          param = options[:param] || "#{options[:value_attr] || attr}_cont"
          text_field_tag("q[#{param}]", params[:q][param], options[:input_html] || {})
        end
      end

      def ac_string_field(attr, options={})
        options.reverse_deep_merge!({input_html: {class: 'ac_field', data: {class: @object.klass.name}}})
        string_field(attr, options)
      end

      def number_field(attr, options={})
        label(attr, options[:label]) + content_tag(:div, class: 'controls') do
          opts = [['=', 'eq'], ['>', 'gt'], ['<', 'lt']].map { |m| [m[0], "#{attr}_#{m[1]}"] }
          current_filter = (opts.detect { |m| params[:q][m[1]].present? } || opts.first)[1]
          select_tag('', options_for_select(opts, current_filter), class: 'input-small predicate-select', id: nil) +
          text_field_tag("q[#{current_filter}]", params[:q][current_filter], class: 'input-small', type: :number)
        end
      end

      def boolean_field(attr, options={})
        content_tag(:div, class: 'pull-left') do
          param = options[:param] || "#{attr}_eq"
          content_tag(:label, class: 'checkbox inline') do
            check_box_tag("q[#{param}]", 1, params[:q][param].to_i == 1, class: 'inline', id: nil) + I18n.t('simple_form.yes')
          end +
          content_tag(:label, class: 'checkbox inline') do
            check_box_tag("q[#{param}]", 0, params[:q][param] && params[:q][param].to_i == 0, class: 'inline', id: nil) + I18n.t('simple_form.no')
          end
        end + label(attr, options[:label], class: 'right-label')
      end

      # Should be used only for string columns
      def presence_field(attr, options={})
        yes_no_field(attr, options.merge(predicates: {yes: %w(present 1), no: %w(present 0)}))
      end

      def null_field(attr, options={})
        yes_no_field(attr, options.merge(predicates: {yes: %w(null 0), no: %w(null 1)}))
      end

      def hidden_field(attr, options={})
        hidden_field_tag("q[#{attr}_eq]", options[:value], options)
      end

      def label(attr, text=nil, options={})
        text ||= @object.klass.han(attr)
        super(attr, text, options)
      end

      def extract_label(attr, options)
        options[:label].presence || @object.klass.han(attr)
      end

      def field_type(attr, options={})
        return options[:as].to_sym if options[:as]
        return :string if attr =~ /^translations_/

        input_type = @object.klass.columns_hash[attr.to_s].try(:type)

        if input_type
          return :select if options[:collection]
          return :string if input_type == :text
        elsif @object.klass.try!(:translates?) && @object.klass.translated?(attr)
          options[:value_attr] = "translations_#{attr}"
          return :string
        elsif assoc = @object.klass.reflect_on_association(attr.to_sym)
          options[:collection] ||= assoc.klass.limit(500)
          options[:value_attr] = "#{attr}_id"
          return :select
        end

        case input_type
          when :timestamp, :datetime, :date
            :date
          when :decimal, :float, :integer
            :number
          else
            input_type or raise "No available input type for #{attr}"
        end
      end

      def yes_no_field(attr, options={})
        predicates = options[:predicates]
        content_tag(:div, class: 'pull-left') do
          content_tag(:label, class: 'checkbox inline') do
            param = "#{attr}_#{predicates[:yes][0]}"
            check_box_tag("q[#{param}]", predicates[:yes][1], params[:q][param] == predicates[:yes][1], class: 'inline', id: nil) + I18n.t('simple_form.yes')
          end +
          content_tag(:label, class: 'checkbox inline') do
            param = "#{attr}_#{predicates[:no][0]}"
            check_box_tag("q[#{param}]", predicates[:no][1], params[:q][param] == predicates[:no][1], class: 'inline', id: nil) + I18n.t('simple_form.no')
          end
        end + label(attr, options[:label], class: 'right-label')
      end
    end
  end
end