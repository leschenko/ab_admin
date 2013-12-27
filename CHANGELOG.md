### 0.4.0

* enhancements
  * add `cached_alt` and `cached_title` columns to Asset model.
  * Fileupload
    * allow to set fileupload container classes via `:container_class` option
    * `:unwrapped` to disable `input_set` wrapper

* deprecation
  * Deprecated `Structure.with_scope` in favor of `Structure.with_type`

* backwards incompatible changes
  * Structure model: renamed `kind` column to `structure_type_id` and `position` renamed to `position_type_id`
  * User model: removed `trust_state` column
  * AdminComment model: renamed `author_id` to `user_id`, `author_name` to `user_name`, `user_id` to `resource_user_id`
  * Devise: see `config.clean_up_csrf_token_on_authentication`, `config.secret_key` config options
  * Fileupload
    * instead of `:file`, `:video` use `file_type: :file` `file_type: :video`
    * instead of `:container` use `:theme` to set subdirectory with fileupload templates
    * asset javascripts template id = "#{file_type}_template"
    * `f.input :picture, as: :uploader` instead of `f.attach_file_field :picture`
    * `script_options` removed