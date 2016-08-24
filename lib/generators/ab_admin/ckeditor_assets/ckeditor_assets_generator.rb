module AbAdmin
  module Generators
    class CkeditorAssetsGenerator < Rails::Generators::Base
      desc 'Copy ckeditor assets to public (prevent it\'s long and buggy precompile)'

      DOWNLOAD_LINK = 'https://dl.dropboxusercontent.com/s/kwzb06hoi9heaoa/ckeditor_assets.tar'

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
