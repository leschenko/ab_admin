module AbAdmin
  module Views
    class SearchFormBuilder < ::Ransack::Helpers::FormBuilder
      delegate :content_tag, :tag, :params,
               :text_field_tag, :check_box_tag, :radio_button_tag, :label_tag, :select_tag,
               :options_for_select, :options_from_collection_for_select, :hidden_field_tag, to: :@template

      def input(attr, options={})
        field_type = field_type(attr, options)
        content_tag :div, class: "clearfix #{field_type} #{options[:wrapper_class]}" do
          send("#{field_type}_field", attr, options)
        end
      end

      def select_field(attr, options={})
        label(attr, options[:label]) + content_tag(:div, class: 'controls') do
          param = options[:param] || "#{options[:value_attr] || attr}_eq"

          if options[:collection].is_a?(Proc)
            collection = options[:collection].call
          else
            collection = options[:collection] || []
          end

          if collection.first.try(:respond_to?, :id)
            collection.map{|r| [AbAdmin.display_name(r), r.id] }
          end

          options[:input_html] ||= {}
          if options[:fancy] || collection.length > 30
            options[:input_html][:class] = [options[:input_html][:class], 'fancy_select'].join(' ')
          end

          html_options = options[:input_html].merge(include_blank: true, id: "q_#{attr}")
          select_tag("q[#{param}]", options_for_select(collection, params[:q][param]), html_options)
        end
      end

      def ac_select_field(attr, options={})
        klass = options[:klass]
        options[:param] ||= "#{options[:value_attr] || attr}_eq"
        pre_select = params.val(:q, options[:param]) ? klass.where(id: params[:q][options[:param]]).map(&:for_input_token) : []
        options[:input_html] ||= {}
        options[:input_html].deep_merge! class: 'fancy_select', data: {class: klass.name, pre: pre_select.to_json}
        string_field attr, options
      end

      def date_field(attr, options={})
        label(attr, options[:label]) + content_tag(:div, class: 'controls') do
          gt_param, lt_param = "#{attr}_gteq", "#{attr}_lteq"
          text_field_tag("q[#{gt_param}]", params[:q][gt_param], class: 'input-small datepicker', autocomplete: 'off') + ' - ' +
          text_field_tag("q[#{lt_param}]", params[:q][lt_param], class: 'input-small datepicker', autocomplete: 'off', id: "q_#{attr}")
        end
      end

      def string_field(attr, options={})
        label(attr, options[:label]) + content_tag(:div, class: 'controls') do
          param = options[:param] || "#{options[:value_attr] || attr}_cont"
          options[:input_html] ||= {}
          options[:input_html][:id] = "q_#{attr}"
          text_field_tag("q[#{param}]", params[:q][param], options[:input_html])
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
          select_tag('', options_for_select(opts, current_filter), class: 'input-small predicate-select') +
          text_field_tag("q[#{current_filter}]", params[:q][current_filter], class: 'input-small')
        end
      end

      def boolean_field(attr, options={})
        content_tag(:div, class: 'pull-left') do
          param = options[:param] || "#{attr}_eq"
          content_tag(:label, class: 'checkbox inline') do
            check_box_tag("q[#{param}]", 1, params[:q][param].to_i == 1, class: 'inline', id: "q_#{attr}") + I18n.t('simple_form.yes')
          end +
          content_tag(:label, class: 'checkbox inline') do
            check_box_tag("q[#{param}]", 0, params[:q][param] && params[:q][param].to_i == 0, class: 'inline') + I18n.t('simple_form.no')
          end
        end + label(attr, options[:label], class: 'right-label')
      end

      def presence_field(attr, options={})
        content_tag(:div, class: 'pull-left') do
          content_tag(:label, class: 'checkbox inline') do
            param = "#{attr}_present"
            check_box_tag("q[#{param}]", 1, params[:q][param].to_i == 1, class: 'inline', id: "q_#{attr}") + I18n.t('simple_form.yes')
          end +
          content_tag(:label, class: 'checkbox inline') do
            param = "#{attr}_null"
            check_box_tag("q[#{param}]", 1, params[:q][param].to_i == 1, class: 'inline') + I18n.t('simple_form.no')
          end
        end + label(attr, options[:label], class: 'right-label')
      end

      def hidden_field(attr, options={})
        hidden_field_tag("q[#{attr}_eq]", options[:value], options)
      end

      def label(attr, text=nil, options={})
        text ||= @object.klass.han(attr)
        super(attr, text, options)
      end

      def field_type(attr, options={})
        return options[:as].to_sym if options[:as]
        return :string if attr =~ /^translations_/

        input_type = @object.klass.columns_hash[attr.to_s].try(:type)

        if input_type
          return :select if options[:collection]
          return :string if input_type == :text
        elsif @object.klass.translates? && @object.klass.translated?(attr)
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
    end
  end
end