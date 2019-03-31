* backwards incompatible changes
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