# encoding: utf-8
require 'ab_admin/version'
require 'ab_admin/core_ext'
require 'ab_admin/engine'

module AbAdmin
  autoload :Utils, 'ab_admin/utils'
  autoload :Devise, 'ab_admin/devise'
  autoload :MenuBuilder, 'ab_admin/menu_builder'
  autoload :AbstractResource, 'ab_admin/abstract_resource'

  module Utils
    autoload :XlsDocument, 'ab_admin/utils/xls_document'
    autoload :CsvDocument, 'ab_admin/utils/csv_document'
    autoload :EvalHelpers, 'ab_admin/utils/eval_helpers'
    autoload :Mysql, 'ab_admin/utils/mysql'
    autoload :Logger, 'ab_admin/utils/logger'
  end

  module Config
    autoload :Table, 'ab_admin/config/base'
    autoload :Search, 'ab_admin/config/base'
    autoload :Export, 'ab_admin/config/base'
    autoload :Form, 'ab_admin/config/base'
    autoload :BaseBuilder, 'ab_admin/config/base'
    autoload :FieldGroup, 'ab_admin/config/base'
    autoload :Field, 'ab_admin/config/base'
  end

  module CarrierWave
    autoload :Glue, 'ab_admin/carrierwave/glue'
    autoload :BaseUploader, 'ab_admin/carrierwave/base_uploader'
    autoload :FileSizeValidator, 'ab_admin/carrierwave/file_size_validator'
  end

  module Concerns
    autoload :AdminAddition, 'ab_admin/concerns/admin_addition'
    autoload :DeepCloneable, 'ab_admin/concerns/deep_cloneable'
    autoload :Silencer, 'ab_admin/concerns/silencer'
    autoload :Utilities, 'ab_admin/concerns/utilities'
    autoload :Headerable, 'ab_admin/concerns/headerable'
    autoload :NestedSet, 'ab_admin/concerns/nested_set'
  end

  module Controllers
    autoload :Callbacks, 'ab_admin/controllers/callbacks'
    autoload :HeadOptions, 'ab_admin/controllers/head_options'
    autoload :Tree, 'ab_admin/controllers/tree'
    autoload :CanCanManagerResource, 'ab_admin/controllers/can_can_manager_resource'
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
    autoload :Structure, 'ab_admin/models/structure'
    autoload :TypeModel, 'ab_admin/models/type_model'
  end

  module Views
    autoload :Helpers, 'ab_admin/views/helpers'
    autoload :AdminHelpers, 'ab_admin/views/admin_helpers'
    autoload :AdminNavigationHelpers, 'ab_admin/views/admin_navigation_helpers'
    autoload :ManagerHelpers, 'ab_admin/views/manager_helpers'
    autoload :FormBuilder, 'ab_admin/views/form_builder'
    autoload :SearchFormBuilder, 'ab_admin/views/search_form_builder'
    autoload :UrlForRoutes, 'ab_admin/views/url_for_routes'

    module Inputs
      autoload :CkeditorInput, 'ab_admin/views/inputs/ckeditor_input'
      autoload :ColorInput, 'ab_admin/views/inputs/color_input'
      autoload :EditorInput, 'ab_admin/views/inputs/editor_input'
      autoload :TreeSelectInput, 'ab_admin/views/inputs/tree_select_input'
      autoload :AssociationInput, 'ab_admin/views/inputs/association_input'
    end
  end

  module Generators
    autoload :ResourceGenerator, 'generators/ab_admin/resource/resource_generator'
    autoload :InstallGenerator, 'generators/ab_admin/install/install_generator'
  end

  mattr_accessor :menu

  mattr_accessor :flash_keys
  @@flash_keys = [:notice, :error]

  mattr_accessor :title_spliter
  @@title_spliter = ' – '

  mattr_accessor :site_name
  @@title_spliter = 'AbAdmin'

  mattr_accessor :devise_layout
  @@devise_layout = 'admin/devise'

  mattr_accessor :image_types
  @@image_types = %w(image/jpeg image/png image/gif image/jpg image/pjpeg image/tiff image/x-png)

  mattr_accessor :display_name_methods
  @@display_name_methods = [:title, :name, :full_name]

  extend Utils

  def self.setup
    yield self
  end

end


