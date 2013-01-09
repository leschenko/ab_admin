# encoding: utf-8
require 'ab_admin/version'
require 'ab_admin/core_ext'

module AbAdmin
  autoload :Utils, 'ab_admin/utils'
  module CarrierWave
    autoload :Glue, 'ab_admin/carrier_wave/glue'
    autoload :BaseUploader, 'ab_admin/carrier_wave/base_uploader'
    autoload :FileSizeValidator, 'ab_admin/carrier_wave/file_size_validator'
  end

  module Concerns
    autoload :AdminAddition, 'ab_admin/concerns/admin_addition'
    autoload :DeepCloneable, 'ab_admin/concerns/deep_cloneable'
    autoload :Silencer, 'ab_admin/concerns/silencer'
    autoload :Utilities, 'ab_admin/concerns/utilities'
  end

  module Controllers
    autoload :Callbacks, 'ab_admin/controllers/callbacks'
    autoload :HeadOptions, 'ab_admin/controllers/head_options'
  end

  module Mailers
    autoload :DevelopmentMailInterceptor, 'ab_admin/mailers/development_mail_interceptor'
    autoload :Helpers, 'ab_admin/mailers/helpers'
    autoload :MailAttachHelper, 'ab_admin/mailers/mail_attach_helper'
  end

  module Models
    autoload :Asset, 'ab_admin/models/asset'
    autoload :AttachmentFile, 'ab_admin/models/attachment_file'
    autoload :Header, 'ab_admin/models/header'
    autoload :Headerable, 'ab_admin/models/headerable'
    autoload :NestedSet, 'ab_admin/models/nested_set'
    autoload :Structure, 'ab_admin/models/structure'
    autoload :TypeModel, 'ab_admin/models/type_model'
  end

  module Views
    autoload :Helpers, 'ab_admin/views/helpers'
    autoload :AdminHelpers, 'ab_admin/views/admin_helpers'
    autoload :FormBuilder, 'ab_admin/views/form_builder'
    autoload :SearchFormBuilder, 'ab_admin/views/search_form_builder'
    autoload :UrlForRoutes, 'ab_admin/views/url_for_routes'
  end

  mattr_accessor :flash_keys
  @@flash_keys = [:notice, :error]

  mattr_accessor :title_spliter
  @@title_spliter = ' – '

  mattr_accessor :image_types
  @@image_types = %w(image/jpeg image/png image/gif image/jpg image/pjpeg image/tiff image/x-png)

  extend Utils

  def self.setup
    yield self
  end
end


