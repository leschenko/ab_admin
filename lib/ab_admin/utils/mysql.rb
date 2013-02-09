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
