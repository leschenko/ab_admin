# -*- encoding : utf-8 -*-
module AbAdmin
  module Generators
    class CkeditorAssetsGenerator < Rails::Generators::Base
      desc 'Copy ckeditor assets to public (prevent it\'s long and buggy precompile)'

      DOWNLOAD_LINK = 'http://dl.dropbox.com/u/48737256/ckeditor_assets.tar'

      def copy_assets
        archive = 'ckeditor_assets.tar'
        path = 'public/javascripts'
        dest = File.join(@destination_stack.last, path)
        empty_directory path
        get DOWNLOAD_LINK, File.join(path, archive)
        run "tar -xf #{dest}/#{archive} -C #{dest}"
      end

    end
  end
end
