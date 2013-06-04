module AbAdmin
  module Concerns
    module AdminAddition
      extend ActiveSupport::Concern

      included do
        scope(:admin, scoped) unless respond_to?(:admin)
        scope(:base, scoped) unless respond_to?(:base)
        scope :ids, lambda { |ids| where("#{quoted_table_name}.id IN (?)", AbAdmin.val_to_array(ids).push(0)) }

        class_attribute :batch_actions, instance_writer: false
        self.batch_actions = [:destroy]
      end

      module ClassMethods
        def for_input_token(r, attr='name_ru')
          {id: r.id, text: r[attr]}
        end
      end

      def for_input_token
        {id: id, text: name}
      end

      def han
        "#{self.class.model_name.human(count: 1)} ##{self.id} #{AbAdmin.safe_display_name(self)}"
      end

      def new_changes
        exclude_attrs = respond_to?(:translated_attribute_names) ? translated_attribute_names.dup : []
        exclude_attrs << :updated_at
        changes.except(*exclude_attrs).map { |k, v| [k, v.last] }.to_hash
      end

      def token_data(method, options={})
        assoc = self.class.reflect_on_association(method)
        records = Array(send(method))
        data = records.map(&:for_input_token)
        data = {
            pre: data.to_json,
            class: assoc.klass.name,
            multi: assoc.collection?,
            c: options.delete(:c)
        }
        if options[:geo_order]
          data[:c] ||= {}
          singular = self.class.model_name.singular
          data[:c].reverse_deep_merge!({with: {lat: "#{singular}_lat", lon: "#{singular}_lon"}})
        end
        if data[:c] && !data[:c].is_a?(String)
          data[:c] = data[:c].to_json
        end
        options.reverse_deep_merge!(class: 'fancy_select', data: data, value: records.map(&:id).join(','))
      end

      def next_prev_by_url(scope, url, prev=false)
        predicates = {'>' => '<', '<' => '>', 'desc' => 'asc', 'asc' => 'desc'}
        query = Rack::Utils.parse_nested_query(URI.parse(url).query).symbolize_keys
        query[:q] ||= {}
        order_str = query[:q]['s'] || 'id desc'
        order_col, order_mode = order_str.split
        quoted_order_col = self.class.quote_column(order_col)
        if prev
          query[:q]['s'] = ["#{order_col} #{predicates[order_mode]}", 'id desc']
          predicate = order_mode == 'desc' ? '>' : '<'
          id_predicate = '<'
        else
          query[:q]['s'] = ["#{order_col} #{order_mode}", 'id']
          predicate = order_mode == 'desc' ? '<' : '>'
          id_predicate = '>'
        end
        sql = "(#{quoted_order_col} #{predicate} :val OR (#{quoted_order_col} = :val AND #{self.class.quote_column('id')} #{id_predicate} #{id}))"
        scope.where(sql, val: send(order_col)).ransack(query[:q]).result(distinct: true).first
      end

    end
  end
end