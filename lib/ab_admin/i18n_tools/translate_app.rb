# -*- encoding : utf-8 -*-
module AbAdmin
  module I18nTools
    class TranslateApp
      def self.call(env)
        if env['warden'].user
          params = Rack::Request.new(env).params
          body = {text: AbAdmin::I18nTools::GoogleTranslate.t(params['q'], params['from'], params['to'])}
          [200, {'Content-Type' => 'application/json'}, body.to_json]
        else
          [401, {'Content-Type' => 'application/json'}, '']
        end
      end
    end
  end
end
