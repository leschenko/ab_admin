require 'rails'
require 'ab_admin'
require 'awesome_nested_set'
require 'inherited_resources'
require 'sunrise-file-upload'
require 'carrierwave'
require 'rack/pjax'
require 'has_scope'
require 'cancan'
require 'enum_field'
require 'the_sortable_tree'
require 'friendly_id'
require 'will_paginate'


module AbAdmin
  class Engine < ::Rails::Engine
    engine_name 'ab_admin'
    isolate_namespace AbAdmin
    
    initializer 'ab_admin.setup' do

      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send :include, AbAdmin::CarrierWave::Glue
        ActiveRecord::Base.send :include, AbAdmin::Utils::Mysql
        ActiveRecord::Base.send :include, AbAdmin::Concerns::DeepCloneable
        ActiveRecord::Base.send :include, AbAdmin::Concerns::Utilities
        ActiveRecord::Base.send :include, AbAdmin::Concerns::Silencer
        ActiveRecord::Base.send :extend,  AbAdmin::Concerns::Silencer
      end

      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.send :include, AbAdmin::Mailers::Helpers
      end

      ActiveSupport.on_load :action_controller do
        ActionController::Base.send :include, AbAdmin::Controllers::HeadOptions
      end

      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, AbAdmin::Views::Helpers
        ActionView::Base.send :include, AbAdmin::Views::AdminHelpers
      end

    end
  end
end
