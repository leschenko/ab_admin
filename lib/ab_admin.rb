require 'inherited_resources'
require 'rack-pjax'
require 'cancan'

require 'ab_admin/version'
require 'ab_admin/core_ext'
require 'ab_admin/engine'

module AbAdmin
  DOMAINNAME_REGEXP = /\A(?:[0-9a-z]\.|[0-9a-z][0-9a-z\-]*[0-9a-z]+\.)+[a-z]{2,6}\z/
  EMAIL_REGEXP = /\A(?#Local part)[_A-Za-z0-9\-+]+(?:\.[_A-Za-z0-9\-+]+)*@(?#Subdomains)(?:[0-9a-z]\.|[0-9a-z][0-9a-z\-]*[0-9a-z]+\.)+(?#TopLevel Domains)[a-z]{2,18}\z/

  autoload :Utils, 'ab_admin/utils'
  autoload :Devise, 'ab_admin/devise'
  autoload :AbstractResource, 'ab_admin/abstract_resource'

  module Config
    autoload :Table, 'ab_admin/config/base'
    autoload :Search, 'ab_admin/config/base'
    autoload :Export, 'ab_admin/config/base'
    autoload :Form, 'ab_admin/config/base'
    autoload :Scope, 'ab_admin/config/base'
    autoload :BaseBuilder, 'ab_admin/config/base'
    autoload :FieldGroup, 'ab_admin/config/base'
    autoload :Field, 'ab_admin/config/base'
    autoload :BatchAction, 'ab_admin/config/base'
    autoload :ActionItem, 'ab_admin/config/base'
    autoload :CustomAction, 'ab_admin/config/base'
    autoload :OptionalDisplay, 'ab_admin/config/optional_display'
  end

  module Menu
    autoload :Builder, 'ab_admin/menu/builder'
    autoload :AbstractBuilder, 'ab_admin/menu/abstract_builder'
    autoload :Group, 'ab_admin/menu/group'
    autoload :BaseGroup, 'ab_admin/menu/base_group'
    autoload :Item, 'ab_admin/menu/item'
  end

  module Utils
    autoload :XlsDocument, 'ab_admin/utils/xls_document'
    autoload :CsvDocument, 'ab_admin/utils/csv_document'
    autoload :EvalHelpers, 'ab_admin/utils/eval_helpers'
    autoload :Mysql, 'ab_admin/utils/mysql'
    autoload :Logger, 'ab_admin/utils/logger'
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
    autoload :Validations, 'ab_admin/concerns/validations'
    autoload :Reloadable, 'ab_admin/concerns/reloadable'
    autoload :HasTracking, 'ab_admin/concerns/has_tracking'
    autoload :AssetHumanNames, 'ab_admin/concerns/asset_human_names'
    autoload :Fileuploads, 'ab_admin/concerns/fileuploads'
    autoload :TranslationsMacro, 'ab_admin/concerns/translations_macro'
  end

  module Controllers
    autoload :Callbacks, 'ab_admin/controllers/callbacks'
    autoload :HeadOptions, 'ab_admin/controllers/head_options'
    autoload :Tree, 'ab_admin/controllers/tree'
    autoload :CanCanManagerResource, 'ab_admin/controllers/can_can_manager_resource'
    autoload :Fv, 'ab_admin/controllers/fv'
  end

  module Mailers
    autoload :Helpers, 'ab_admin/mailers/helpers'
    autoload :MailAttachHelper, 'ab_admin/mailers/mail_attach_helper'
  end

  module Models
    autoload :Asset, 'ab_admin/models/asset'
    autoload :AttachmentFile, 'ab_admin/models/attachment_file'
    autoload :Header, 'ab_admin/models/header'
    autoload :Structure, 'ab_admin/models/structure'
    autoload :TypeModel, 'ab_admin/models/type_model'
    autoload :Locator, 'ab_admin/models/locator'
    autoload :Settings, 'ab_admin/models/settings'
    autoload :User, 'ab_admin/models/user'
    autoload :Track, 'ab_admin/models/track'
    autoload :AdminComment, 'ab_admin/models/admin_comment'
  end

  module Views
    autoload :Helpers, 'ab_admin/views/helpers'
    autoload :AdminHelpers, 'ab_admin/views/admin_helpers'
    autoload :AdminNavigationHelpers, 'ab_admin/views/admin_navigation_helpers'
    autoload :ManagerHelpers, 'ab_admin/views/manager_helpers'
    autoload :FormBuilder, 'ab_admin/views/form_builder'
    autoload :SearchFormBuilder, 'ab_admin/views/search_form_builder'
    autoload :UrlForRoutes, 'ab_admin/views/url_for_routes'
    autoload :ContentOnlyWrapper, 'ab_admin/views/content_only_wrapper'
    autoload :WillPaginateBootstrapRenderer, 'ab_admin/views/will_paginate_bootstrap_renderer'

    module Inputs
      autoload :CkeditorInput, 'ab_admin/views/inputs/ckeditor_input'
      autoload :ColorInput, 'ab_admin/views/inputs/color_input'
      autoload :EditorInput, 'ab_admin/views/inputs/editor_input'
      autoload :DateTimePickerInput, 'ab_admin/views/inputs/date_time_picker_input'
      autoload :TokenInput, 'ab_admin/views/inputs/token_input'
      autoload :UploaderInput, 'ab_admin/views/inputs/uploader_input'
    end
  end

  module I18nTools
    autoload :TranslateApp, 'ab_admin/i18n_tools/translate_app'
    autoload :GoogleTranslate, 'ab_admin/i18n_tools/google_translate'
    autoload :ModelTranslator, 'ab_admin/i18n_tools/model_translator'
  end

  module Generators
    autoload :ResourceGenerator, 'generators/ab_admin/resource/resource_generator'
    autoload :InstallGenerator, 'generators/ab_admin/install/install_generator'
    autoload :ModelGenerator, 'generators/ab_admin/model/model_generator'
    autoload :CkeditorAssetsGenerator, 'generators/ab_admin/ckeditor_assets/ckeditor_assets_generator'
  end

  mattr_accessor :menu
  mattr_accessor :body_css_class
  mattr_accessor :favicon_path
  mattr_accessor :footer_notes
  mattr_accessor :default_url_options
  mattr_accessor :locale
  mattr_accessor :root_path
  mattr_accessor :base_url

  mattr_accessor :flash_keys
  @@flash_keys = [:notice, :error]

  mattr_accessor :title_splitter
  @@title_splitter = ' – '

  mattr_accessor :site_name
  @@site_name = 'AbAdmin'

  mattr_accessor :footer
  @@footer = true

  mattr_accessor :devise_layout
  @@devise_layout = 'admin/devise'

  mattr_accessor :image_types
  @@image_types = %w(image/jpeg image/png image/gif image/jpg image/pjpeg image/tiff image/x-png)

  mattr_accessor :display_name_methods
  @@display_name_methods = [:title, :name, :full_name, :id]

  mattr_accessor :translate_models
  @@translate_models = %w(User Asset Structure StaticPage Header AdminComment)

  mattr_accessor :assets
  @@assets = %w(ab_admin/devise.css bootstrap.js ab_admin/loading.gif ab_admin/clear.png ab_admin/clear.png)

  mattr_accessor :test_settings
  @@test_settings = {}

  mattr_accessor :fileupload_url
  @@fileupload_url = '/admin/assets'

  mattr_accessor :uploads_dir
  @@uploads_dir = 'uploads'

  mattr_accessor :time_format
  @@time_format = '%d.%m.%y %H:%M'

  mattr_accessor :default_permitted_params
  @@default_permitted_params = [:fileupload_guid]

  mattr_accessor :translated_locales
  @@translated_locales = []

  mattr_accessor :locale_to_country_code
  @@locale_to_country_code = {ja: :jp, en: :gb, uk: :ua}

  mattr_accessor :default_resource_settings
  @@default_resource_settings = {
      index_views: [:table],
      search: true,
      export: true,
      batch: true,
      hotkeys: true,
      button_scopes: true,
      list_dblclick: true,
      max_per_page: 10_000,
      per_page_variants: [50, 100, 500, 1000],
      default_per_page: 50,
      view_default_per_page: Hash.new { 50 }.update(table: 50, tree: 1000, map: 1000),
      pagination_index_views: [:table, :grid],
      collection_actions: %w(index search batch rebuild),
      id_column_with_created_at: true
  }

  extend Utils

  def self.setup
    yield self
  end
end


