module AbAdmin
  module Utils
    module Mysql
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Deletes all rows in table very fast, but without calling +destroy+ method
        # nor any hooks.
        def truncate!
          transaction { connection.execute("TRUNCATE TABLE #{quoted_table_name};") }
        end

        # remove duplicate records by columns
        def remove_duplicates(*cols, deleted_id_order: '<')
          conds = cols.map { |col| "#{table_name}.#{col} IS NOT NULL AND #{table_name}.#{col} = t.#{col}" }.join(' AND ')
          query = <<-SQL
            DELETE FROM #{table_name} USING #{table_name}, #{table_name} AS t WHERE #{table_name}.id #{deleted_id_order} t.id AND #{conds}
          SQL
          connection.execute(query)
        end


        # Disables key updates for model table
        def disable_keys
          connection.execute("ALTER TABLE #{quoted_table_name} DISABLE KEYS")
        end

        # Enables key updates for model table
        def enable_keys
          connection.execute("ALTER TABLE #{quoted_table_name} ENABLE KEYS")
        end

        # Disables keys, yields block, enables keys.
        def with_keys_disabled
          disable_keys
          yield
          enable_keys
        end
      end
    end
  end
end
