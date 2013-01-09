# -*- encoding : utf-8 -*-
module AbAdmin
  module Concerns
    module Silencer

      def no_timestamps(&block)
        original_setting = ActiveRecord::Base.record_timestamps
        ActiveRecord::Base.record_timestamps = false
        begin
          yield
        ensure
          ActiveRecord::Base.record_timestamps = original_setting
        end
      end

      def no_versions(&block)
        original_setting = PaperTrail.enabled?
        PaperTrail.enabled = false
        begin
          yield
        ensure
          PaperTrail.enabled = original_setting
        end
      end

      def full_silence(&block)
        no_timestamps do
          no_versions(&block)
        end
      end

    end
  end
end