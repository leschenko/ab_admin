require 'rails'
require 'ab_admin'

module AbAdmin
  class Engine < ::Rails::Engine
    engine_name 'ab_admin'
    isolate_namespace AbAdmin
    
    initializer 'ab_admin.setup' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send :include, AbAdmin::CarrierWave::Glue
        ActiveRecord::Base.send :include, AbAdmin::Utils::Mysql
      end
      
      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, AbAdmin::Views::Helper
      end
    end
    
    #initializer 'ab_admin.csv_renderer' do
    #  ::ActionController::Renderers.add :csv do |collection, options|
    #    doc = AbAdmin::Utils::CsvDocument.new(collection, options)
    #    send_data(doc.render, :filename => doc.filename, :type => Mime::CSV, :disposition => 'attachment')
    #  end
    #end
  end
end
