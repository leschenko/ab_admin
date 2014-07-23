module AbAdmin
  module Utils
    autoload :CSVBuilder, 'ab_admin/utils/csv_builder'
    autoload :EvalHelpers, 'ab_admin/utils/eval_helpers'
    autoload :Logger, 'ab_admin/utils/logger'
    autoload :Mysql, 'ab_admin/utils/mysql'

    def load_files!(base_path = 'lib/utils')
      Dir[Rails.root.join("#{base_path}/**/*.rb")].each do |path|
        require_dependency path
      end
    end

    def bm(message = 'Benchmarking', options = {})
      result = nil
      ms = Benchmark.ms { result = yield }
      (options[:logger] || Rails.logger).info '%s (%.3fms)' % [message, ms]
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
      text = raw_text.to_s.gsub(/&quot;|&laquo;|&raquo;|&#x27;/, '\'').gsub(/&nbsp;/, ' ').gsub(/&mdash;/, '-').no_html.squish
      text.truncate(size, separator: ' ')
    end

    def l_path(locale=nil)
      locale ||= I18n.locale
      locale == I18n.default_locale ? '' : "/#{locale}"
    end

    alias :locale_path :l_path

    def rss_text(raw_html)
      Rack::Utils.escape_html(raw_html.no_html.squish)
    end

    # html like: '<!-- html comment --><script>script content</script><div>div content</div><p>p content</p>'
    # normalized to: "<p>div content</p><p>p content</p>"
    def normalize_html(raw_html, &block)
      @@sanitizer ||= Sanitizer.new
      @@sanitizer.normalize_html(raw_html, &block)
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

    def full_url(path)
      return path if path =~ %r{^(http|//)}
      host = AbAdmin.base_url || Rails.application.config.action_mailer.default_url_options[:host] || 'www.example.com'
      "http://#{host}#{path}"
    end

    def js_date_data
      {
          formats: I18n.t('date.formats'),
          day_names: I18n.t('date.day_names'),
          abbr_day_names: I18n.t('date.common_abbr_day_names'),
          month_names: I18n.t('date.common_month_names'),
          standalone_month_names: I18n.t('date.standalone_month_names'),
          abbr_month_names: I18n.t('date.abbr_month_names')
      }
    end

    class Sanitizer
      include ActionView::Helpers::SanitizeHelper

      CLEAN_HTML_COMMENTS_REGEXP = /(&lt;|<)\!--.*?--(&gt;|>)/m
      CLEAN_LINE_BREAKS_REGEXP = /[^>]\r\n/

      def normalize_html(raw_html)
        return '' if raw_html.blank?
        cleaned_html = raw_html.gsub(CLEAN_HTML_COMMENTS_REGEXP, '')#.gsub(CLEAN_LINE_BREAKS_REGEXP, '<br/>')
        html = sanitize(cleaned_html)
        doc = Nokogiri::HTML.fragment(html)
        #doc.xpath('comment()').each { |c| c.remove }
        yield doc if block_given?
        doc.search('div').each { |el| el.name = 'p' }
        doc.to_html
      end
    end

    @@display_name_methods_cache = {}
    def display_name_method_for(resource)
      @@display_name_methods_cache[resource.class.name] ||= AbAdmin.display_name_methods.find { |method| resource.respond_to? method }
    end

    def display_name(resource)
      return unless resource
      resource.send(display_name_method_for(resource)).to_s.no_html
    end

    def safe_display_name(resource)
      return unless display_name_method_for(resource)
      display_name(resource)
    end

    def pretty_data(object)
      case object
        when String, Integer, BigDecimal, Float
          object
        when TrueClass
          '+'
        when FalseClass
          '-'
        when Date, DateTime, Time, ActiveSupport::TimeWithZone
          I18n.l(object, format: :long)
        when NilClass
          ''
        else
          AbAdmin.safe_display_name(object) || object
      end
    end

    def test_env?
      Rails.env.test? || Rails.env.cucumber?
    end

    def friendly_token(n=10)
      SecureRandom.base64(16).tr('+/=', 'xyz').first(n)
    end
  end
end