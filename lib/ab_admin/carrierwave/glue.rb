module AbAdmin
  module CarrierWave
    module Glue
      extend ActiveSupport::Concern

      module ClassMethods
        def ab_admin_uploader(uploader=nil, options={}, &block)
          options.reverse_merge!(mount_on: :data_file_name)
          options.merge!(validate_integrity: false, validate_processing: false, validate_download: false) unless uploader.try!(:enable_processing)
          
          mount_uploader(:data, uploader, options, &block)
        end

        def validates_filesize_of(*attr_names)
          validates_with FileSizeValidator, _merge_attributes(attr_names)
        end
      end
      
    end
  end
end
