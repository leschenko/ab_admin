# -*- encoding : utf-8 -*-
module AbAdmin
  module Concerns
    module Utilities
      extend ActiveSupport::Concern

      included do
        delegate :value_to_boolean, to: ActiveRecord::ConnectionAdapters::Column
      end

      module ClassMethods
        def max_time
          Rails.cache.fetch("by_class_#{name}", expires_in: 60) { unscoped.maximum(:updated_at).to_i }
        end

        def max_time_by_scope(scope)
          Rails.cache.fetch("by_class_#{name}_#{scope}", expires_in: 60) { unscoped.send(scope).maximum(:updated_at).to_i }
        end

        def full_truncate(with_destroy=true)
          destroy_all if with_destroy
          truncate!
          const_get(:Translation).truncate! if try!(:translates?)
        end

        def all_ids
          select(:id).map(&:id)
        end

        def all_models
          Dir.glob(Rails.root.to_s + '/app/models/**/*.rb').each { |file| require file }
          ActiveRecord::Base.descendants.find_all { |model| model.table_exists? }
          #ActiveRecord::Base.descendants.find_all { |model| model.descends_from_active_record? }
        end

        def han(attr)
          human_attribute_name(attr)
        end

        def quote_column(col_name)
          "#{quoted_table_name}.#{connection.quote_column_name(col_name)}"
        end

        def update_counter_columns(*args)
          args.each do |counter_column|
            assoc = reflect_on_association(counter_column.to_s.sub(/_count$/, '').to_sym)
            if assoc
              count_klass = assoc.klass
              query = <<-SQL
                UPDATE #{quoted_table_name} SET #{counter_column} = (SELECT COUNT(#{count_klass.quoted_table_name}.id)
                  FROM #{count_klass.quoted_table_name}
                  WHERE #{quoted_table_name}.id = #{count_klass.quoted_table_name}.#{assoc.foreign_key})
              SQL
              connection.execute(query)
            end
          end
        end

        def update_counter_column(col, assoc_method)
          assoc = assoc_count = reflect_on_association(assoc_method)
          if assoc
            add_from = ''
            add_cond = ['1=1']
            if assoc.options[:through]
              assoc_count = reflect_on_association(assoc.options[:through])
              unless assoc.klass.table_name.to_s == table_name.to_s
                add_from = "INNER JOIN #{assoc.klass.quoted_table_name} ON #{assoc_count.klass.quoted_table_name}.#{assoc.foreign_key} = #{assoc.klass.quoted_table_name}.id"
              end
            end
            add_cond << "#{assoc.klass.quoted_table_name}.#{assoc.type} = '#{name}'" if assoc.type
            add_cond += assoc.klass.instance_exec(&assoc.scope).where_values.map(&:to_sql) if assoc.scope
            if assoc.klass.default_scopes.present?
              assoc.klass.default_scopes.each do |scope|
                add_cond += assoc.klass.instance_exec(&scope.instance_variable_get(:@scope)).where_values.map(&:to_sql)
              end
            end
            count_klass = assoc_count.klass
            query = <<-SQL
                UPDATE #{quoted_table_name} SET #{col} = (SELECT COUNT(#{count_klass.quoted_table_name}.id)
                  FROM #{count_klass.quoted_table_name} #{add_from}
                  WHERE #{quoted_table_name}.id = #{count_klass.quoted_table_name}.#{assoc_count.foreign_key} AND #{add_cond.join(' AND ')})
            SQL
            connection.execute(query)
          end
        end

        def all_translated_attribute_names
          if translates?
            ::I18n.available_locales.map do |loc|
              translated_attribute_names.map { |attr| "#{attr}_#{loc}" }
            end.flatten
          else
            []
          end
        end

        def all_columns_names
          ActiveSupport::Deprecation.warn('#all_columns_names is deprecated without replacement')
          if translates?
            column_names + all_translated_attribute_names + translated_attribute_names.map(&:to_s)
          else
            column_names
          end
        end

        def generate_token(column=:guid)
          loop do
            token = AbAdmin.friendly_token
            break token unless to_adapter.find_first({column => token})
          end
        end

        def friendly_find(*args)
          find(*args)
        end
      end

      def compare_key
        "#{self.class.model_name.singular}_#{id}"
      end

      def generate_token(column=:guid)
        begin
          self[column] = AbAdmin.friendly_token
        end while self.class.exists?(column => self[column])
        self[column]
      end

      def ensure_token(column=:guid)
        return self[column] if self[column].present?
        generate_token(column)
        update_column(column, self[column]) unless new_record?
        self[column]
      end
    end

  end
end
