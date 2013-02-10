# -*- encoding : utf-8 -*-
module AbAdmin
  module Generators
    class CkeditorAssetsGenerator < Rails::Generators::Base
      desc 'Copy ckeditor assets to public (prevent it\'s long and buggy precompile)'

      source_root File.expand_path('../templates', __FILE__)

      def copy_assets
        directory 'ckeditor', 'public/javascripts/ckeditor'
      end

    end
  end
end
