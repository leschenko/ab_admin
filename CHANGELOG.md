* backwards incompatible changes
  * removed `call_method_or_proc_on`, use `method_or_proc_on` instead
  * removed collection batch action as rarely used
  * rename table builder option `row_class` to `row_html_class`
  * rename table builder option `cell_class` to `cell_html_class`
  * removed `devise-encryptable` gem
  * rename AbAdmin#time_format to AbAdmin#datetime_format

### 0.9.0
* backwards incompatible changes
  * removed fancybox, JCrop without replacement
  * removed `:crop` option from uploader
  * removed `globalize` gem
  * removed AdminAddition unused methods
  * removed User::managers scope 
  * removed User login generation
  * removed User instance methods: init,  has_role?, set_default_role
  * removed `require_admin` controller helper
  * controller and view `moderator?` helper returns false for `admin` role now
  * added `AbAdmim.default_resource_settings` for all resource configuration
  * removed `AbAdmin.current_index_view` and `current_index_view`, use `settings[:current_index_view]` instead
  * removed `AbAdmin.per_page` and `per_page`, use `settings[:per_page]` instead
  * removed `AbAdmin.max_per_page` and `max_per_page`, use `settings[:max_per_page]` instead
  * removed `AbAdmin.per_page_variants`, use `settings[:per_page_variants]` instead
  * removed `AbAdmin.view_default_per_page`, use `settings[:view_default_per_page]` instead
  * removed `settings[:skip_pagination]`, use `settings[:pagination_index_views]` or `settings[:pagination]` instead
  * removed `call_method_or_proc_on`, use `method_or_proc_on` instead
  * removed `AbAdmin.default_per_page`
  * use `custom_settings` controller method for settings customization
  * `index_view` renamed to `index_views` and allow only array of symbols
* deprecation
  * Array#without! is deprecated without replacement

### 0.8.3
* backwards incompatible changes
  * rename `Hash#store_multi` to `Hash#dig_store`
  * `String#to_utc` removed without replacement
  * `String#is_int?` removed without replacement
  * `String#is_number?` removed without replacement
  * `String#mb_downcase` removed without replacement
  * `String#mb_upcase` removed without replacement
  * `String#clean_text` removed without replacement
  * `String::randomize` removed without replacement
  * `String#count_words` removed without replacement
  * `String#words_count` removed without replacement
  * `String#tr_lang` removed without replacement
  * `String#capitalize_first` removed without replacement
  * `String#lucene_escape` removed without replacement
  * `Hash#try_keys` removed without replacement
  * `Nil#val` removed without replacement
  * `Hash#val` removed without replacement
  * `Array#add_or_delete` removed without replacement
  * `Array#word_count` removed without replacement
  * `Array#map_val` removed without replacement
  * `Array#val_detect` removed without replacement

### 0.8.3
* backwards incompatible changes
  * `list_sort_link` accept only options Hash as second argument
  * `deprecated_utils.js` removed without replacement
  * `Settings.load_config` is deprecated, use `Settings.data` instead
  * `call_method_or_proc_on` don't accept method name as String, use Symbol instead
  * `call_method_or_proc_on` use `public_send` instead of `sent` for method call

### 0.8.0
* backwards incompatible changes
  * removed Asset#format_created_at
  * removed Time#formatted_datetime, Time#formatted_date
  * date picker format changed to `yyyy-mm-dd` 
  * Deprecated `Hash#no_blank` in favor of `Hash#reject_blank`

### 0.7.0
* enhancements
  * add setting `search_form: {compact_labels: true}` to use compact labels in search form 
* backwards incompatible changes
  * [MARKUP] Tooltip css class 'do_tooltip' changed to 'js-tooltip', removed default tooltip position
  * [MARKUP] Deprecated :wrapper_class option in search form, use `wrapper_html: {class: ''}` instead

### 0.5.0

* backwards incompatible changes
  * removed custom time and date formats (`:api`, `:path`, `:compare`, `:compare_date`)
  * remove `russian` gem and related hook,
    for proper day names add `Russian::LOCALIZE_MONTH_NAMES_MATCH = /(%d|%e|%-d)(.*)(%B)/ if defined? Russian`
    or use gem from github
  * removed Hash#to_hash method
  * removed `capture_block` input, because `simple_form` provide it natively

* deprecation
  * Deprecated second bool argument in `id_link` helper, use `id_link(item, edit: false)` instead


### 0.4.0

* enhancements
  * add `cached_alt` and `cached_title` columns to Asset model.
  * Fileupload
    * allow to set fileupload container classes via `:container_class` option
    * `:unwrapped` to disable `input_set` wrapper

* deprecation
  * Deprecated `Structure.with_kind` in favor of `Structure.with_type`

* backwards incompatible changes
  * Structure model: renamed `kind` column to `structure_type_id` and `position` renamed to `position_type_id`
  * User model: removed `trust_state` column
  * AdminComment model: renamed `author_id` to `user_id`, `author_name` to `user_name`, `user_id` to `resource_user_id`
  * Devise: see `config.clean_up_csrf_token_on_authentication`, `config.secret_key` config options
  * Fileupload
    * remove 'sunrise-file-upload' and 'fine-uploader'
    * instead of `:file`, `:video` use `file_type: :file` `file_type: :video`
    * instead of `:container` use `:theme` to set subdirectory with fileupload templates
    * `:file_max_size` option renamed to `:max_size`
    * asset javascripts template id = "#{file_type}_template"
    * `f.input :picture, as: :uploader` instead of `f.attach_file_field :picture`
    * `script_options` removed
  * `gon` gem removed, use `fv` instead (`fv` is an OpenStruct)