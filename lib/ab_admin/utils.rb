module AbAdmin
  module Utils
    autoload :CSVBuilder, 'ab_admin/utils/csv_builder'
    autoload :EvalHelpers, 'ab_admin/utils/eval_helpers'
    autoload :Logger, 'ab_admin/utils/logger'
    autoload :Mysql, 'ab_admin/utils/mysql'

    #extend self

    def load_files!(path = 'lib/utils')
      Dir[Rails.root.join("#{path}/**/*.rb")].each do |path|
        require_dependency path
      end
    end

    def bm(message = "Benchmarking", options = {})
      result = nil
      ms = Benchmark.ms { result = yield }
      Rails.logger.debug '%s (%.3fms)' % [message, ms]
      result
    end

    def pretty(raw_data)
      data = case raw_data
               when Hash
                 raw_data
               when String
                 MultiJson.decode(raw_data)
             end
      JSON.pretty_generate data
    end

    def val_to_array(val, zero=false)
      return [] unless val
      a = val.is_a?(Array) ? val : val.to_s.split(',').map(&:to_i)
      zero ? a : a.without(0)
    end

    def val_to_array_s(val)
      return [] unless val
      val.is_a?(Array) ? val : val.split(',').map(&:to_s).without(0)
    end

    def truncate_text(raw_text, size=200)
      text = raw_text.to_s.gsub(/&quot;|&laquo;|&raquo;|&#x27;/, "'").gsub(/&nbsp;/, ' ').gsub(/&mdash;/, '-').no_html.squish
      text.truncate(size, :separator => ' ')
    end

    def l_path(locale=nil)
      return '' unless locale
      locale == I18n.default_locale ? '' : "/#{locale}"
    end

    def rss_text(raw_html)
      Rack::Utils.escape_html(raw_html.no_html.squish)
    end

    #AbAdmin.normalize_html('<!--das asd as as as--><script>asd</script><div>dasd</div><p>asdasd</p>')
    #=> "<p>dasd</p><p>asdasd</p>"
    def normalize_html(raw_html)
      @@sanitizer ||= Sanitizer.new
      @@sanitizer.normalize_html(raw_html)
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

    def full_url(path)
      host = Rails.application.config.action_mailer.default_url_options[:host] || 'www.example.com'
      "http://#{host}#{path}"
    end

    def js_date_data
      {
          :formats => I18n.t('date.formats'),
          :day_names => I18n.t('date.day_names'),
          :abbr_day_names => I18n.t('date.common_abbr_day_names'),
          :month_names => I18n.t('date.common_month_names'),
          :standalone_month_names => I18n.t('date.standalone_month_names'),
          :abbr_month_names => I18n.t('date.abbr_month_names')
      }
    end

    class Sanitizer
      include ActionView::Helpers::SanitizeHelper

      def normalize_html(raw_html)
        return '' if raw_html.blank?
        html = sanitize(raw_html.gsub(/<!--(.*?)-->[\n]?/m, ""))
        doc = Nokogiri::HTML.fragment(html)
        #doc.xpath('comment()').each { |c| c.remove }
        doc.search('div').each { |el| el.name = 'p' }
        doc.to_html
      end
    end
  end
end