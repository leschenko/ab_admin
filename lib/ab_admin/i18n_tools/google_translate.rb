# -*- encoding : utf-8 -*-
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
            key: configatron.else.retrieve(:google_api_key, ENV['GOOGLE_API_KEY']),
            format: 'html',
            source: from,
            target: to,
            q: text
        }
        response = RestClient.post(base, params, 'X-HTTP-Method-Override' => 'GET')

        if response.code == 200
          json = MultiJson.decode(response)
          json['data']['translations'][0]['translatedText']
        else
          raise StandardError, response.inspect
        end
      end
    end
  end
end
