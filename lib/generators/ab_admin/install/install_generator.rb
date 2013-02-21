# -*- encoding : utf-8 -*-
module AbAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Creates a AbAdmin initializer and copy general files to your application.'

      source_root File.expand_path('../templates', __FILE__)

      # copy uploaders
      def copy_uploaders
        directory 'uploaders', 'app/uploaders'
      end

      def copy_configurations
        template('config/ab_admin.rb.erb', 'config/initializers/ab_admin.rb')

        template('config/database.yml', 'config/database.yml.sample')
        copy_file('config/seeds.rb', 'db/seeds.rb')

        copy_file('config/i18n-js.yml', 'config/i18n-js.yml')

        template('config/logrotate-config', 'config/logrotate-config')
        template('config/nginx.conf', 'config/nginx.conf')
        template('script/unicorn.sh', 'script/unicorn.sh')
        template('config/settings.yml', 'config/settings/settings.yml')
        template('config/settings.yml', 'config/settings/settings.local.yml')
        copy_file('config/unicorn_config.rb', 'config/unicorn_config.rb')
        copy_file 'gitignore', '.gitignore'
      end

      # copy models
      def copy_models
        directory 'models', 'app/models/defaults'
        copy_file 'config/admin_menu.rb', 'app/models/admin_menu.rb'
      end

      # copy helpers
      def copy_helpers
        copy_file 'helpers/admin/structures_helper.rb', 'app/helpers/admin/structures_helper.rb'
      end

      # Add devise routes
      def add_routes
        route 'devise_for :users, ::AbAdmin::Devise.config'
        route 'root to: redirect(\'/users/sign_in\')'
      end

      def autoload_paths
        log :autoload_paths, 'models/defaults'
        sentinel = /\.autoload_paths\s+\+=\s+\%W\(\#\{config\.root\}\/extras\)\s*$/

        code = 'config.autoload_paths += %W(#{config.root}/app/models/defaults #{config.root}/app/models/ab_admin)'

        in_root do
          inject_into_file 'config/application.rb', "    #{code}\n", {after: sentinel, verbose: false}
        end
      end

      def copy_specs
        directory 'spec', 'spec'
        copy_file 'rspec', '.rspec'
      end

      protected

      def app_name
        @app_name ||= defined_app_const_base? ? defined_app_name : File.basename(destination_root)
      end

      def defined_app_name
        defined_app_const_base.underscore
      end

      def defined_app_const_base
        Rails.respond_to?(:application) && defined?(Rails::Application) &&
            Rails.application.is_a?(Rails::Application) && Rails.application.class.name.sub(/::Application$/, '')
      end

      alias :defined_app_const_base? :defined_app_const_base

      def app_const_base
        @app_const_base ||= defined_app_const_base || app_name.gsub(/\W/, '_').squeeze('_').camelize
      end

      def app_const
        @app_const ||= "#{app_const_base}::Application"
      end

      def app_path
        @app_path ||= Rails.root.to_s
      end

    end
  end
end
