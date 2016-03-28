module AbAdmin
  module Concerns
    module Reloadable
      extend ActiveSupport::Concern

      included do
        class_attribute :reload_checker
      end

      module ClassMethods
        def has_reload_check(key=nil, logger=nil, &block)
          self.reload_checker = ::AbAdmin::Concerns::Reloadable::Reloader.new(key, logger, &block)
        end

        def check_reload
          self.reload_checker.check
        end
      end

      class Reloader

        def initialize(key=nil, logger=nil, &block)
          @key = key || "#{model_name.singular}_check_reload_key"
          @block = block
          @logger = logger || Rails.logger
          @stamp = fetch_stamp
          log "init #@key with value #@stamp"
        end

        def fetch_stamp
          Rails.cache.fetch(@key) { Time.now.to_i }
        end

        def check
          stamp = fetch_stamp
          if @stamp != stamp
            @stamp = stamp
            @block.call()
            log "#@key reloaded to #@stamp"
          end
        end

        def expire
          log "#@key expire"
          Rails.cache.delete(@key)
        end

        def log(msg)
          @logger.info "[RELOADER] (#{Process.pid}) #{msg}"
        end
      end
    end
  end
end