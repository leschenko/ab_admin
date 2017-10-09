module AbAdmin
  module Utils
    module Logger
      class ExtendedLogger < ::Logger
        def exception(e, options={})
          message = "#{e.message} #{"DATA:#{options[:data].inspect}" if options && options[:data]}"
          backtrace = e.backtrace.map { |l| "#{' ' * 2}#{l}" }.join("\n")
          error("#{e.class} #{message}\n#{backtrace}\n\n")
        end

        def reopen
          @logdev = LogDevice.new(@logdev.filename)
        end
      end

      class Formatter
        FORMAT = "[%s] %5s %s\n".freeze
        DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%S.%3N'.freeze

        def call(severity, time, _, msg)
          FORMAT % [time.strftime(DATETIME_FORMAT), severity, msg]
        end
      end

      def self.for_file(filename)
        logger = ExtendedLogger.new(Rails.root.join('log', filename))
        logger.formatter = Formatter.new
        logger
      end
    end
  end
end