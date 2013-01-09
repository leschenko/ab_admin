# encoding: utf-8
module AbAdmin
  module CarrierWave
    module Glue
      extend ActiveSupport::Concern

      module ClassMethods
        def sunrise_uploader(uploader=nil, options={}, &block)
          options = { :mount_on => :data_file_name }.merge(options)
          
          mount_uploader(:data, uploader, options, &block)
          
          validates_processing_of :data
        end
        
        def validates_filesize_of(*attr_names)
          validates_with FileSizeValidator, _merge_attributes(attr_names)
        end
      end
      
    end
  end
end
