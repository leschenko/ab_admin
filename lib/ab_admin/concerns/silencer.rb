# -*- encoding : utf-8 -*-
module AbAdmin
  module Concerns
    module Silencer

      def no_timestamps
        original_setting = ActiveRecord::Base.record_timestamps
        ActiveRecord::Base.record_timestamps = false
        begin
          yield
        ensure
          ActiveRecord::Base.record_timestamps = original_setting
        end
      end

      def no_versions
        versions_const = get_versions_const
        yield and return unless versions_const
        original_setting = versions_const.enabled?
        versions_const.enabled = false
        begin
          yield
        ensure
          versions_const.enabled = original_setting
        end
      end

      def full_silence(&block)
        no_timestamps do
          no_versions(&block)
        end
      end

      def get_versions_const
        if defined? PaperTrail
          PaperTrail
        elsif defined? PublicActivity
          PublicActivity
        else
          nil
        end
      end

    end
  end
end