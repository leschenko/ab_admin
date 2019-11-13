require 'multi_json'
require 'rest-client'

module AbAdmin
  module I18nTools
    module GoogleTranslate
      def self.t(text, from, to)
        return '' if text.blank?
        return text if from == to
        base = 'https://www.googleapis.com/language/translate/v2'
        params = {
            key: ENV['GOOGLE_API_KEY'] || Settings.data.else.try!(:google_api_key),
            format: 'html',
            source: from,
            target: to,
            q: text
        }
        response = RestClient.post(base, params, 'X-HTTP-Method-Override' => 'GET')

        if response.code == 200
          json = MultiJson.decode(response)
          res = json['data']['translations'][0]['translatedText'].to_s.gsub(/%\s{/, ' %{')
          res = "#{res[0].upcase}#{res[1..-1]}" if text.first[/[[:upper:]]/]
          res
        else
          raise StandardError, response.inspect
        end
      end
    end
  end
end
