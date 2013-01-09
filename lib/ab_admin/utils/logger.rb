module AbAdmin
  module Utils
    module Logger

      class ShortFormatter < ::Logger::Formatter
        def call(severity, time, progname, msg)
          "[#{time.strftime("%Y-%m-%dT%H:%M:%S")}] #{msg}\n"
        end
      end

      def self.for_file(filename)
        logfile = File.open(Rails.root.join('log', filename), 'a+')
        logfile.sync = true
        logger = ::Logger.new(logfile)
        logger.formatter = ShortFormatter.new
        logger
      end

    end
  end
end