module AbAdmin
  module Concerns
    module AdminAddition
      extend ActiveSupport::Concern

      included do
        attr_accessor :last_updated_timestamp
        validate :do_not_overwrite
        scope(:admin, proc { all }) unless respond_to?(:admin)
        scope(:base, -> { all }) unless respond_to?(:base)
        scope :by_ids, lambda { |ids| where("#{quoted_table_name}.id IN (?)", AbAdmin.val_to_array(ids).push(0)) } unless respond_to?(:by_ids)

        class_attribute :batch_actions, instance_writer: false
        self.batch_actions = [:destroy]
      end

      def do_not_overwrite
        return if new_record? || last_updated_timestamp.blank?
        errors.add(:base, :changed) if updated_at.to_i > last_updated_timestamp
      end

      def for_input_token
        {id: id, text: AbAdmin.safe_display_name(self).to_s}
      end

      def han
        "#{self.class.model_name.human(count: 1)} ##{self.id} #{AbAdmin.safe_display_name(self)}"
      end

      def token_data(method, options={})
        assoc = self.class.reflect_on_association(method)
        scope = send(method)
        scope = scope.reorder("#{assoc.options[:through]}.position") if options[:sortable]
        records = Array(scope)
        data = records.map(&:for_input_token)
        data = {
            pre: data.to_json,
            class: assoc.klass.name,
            multi: assoc.collection?,
            c: options.delete(:c),
            sortable: options.delete(:sortable)
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
