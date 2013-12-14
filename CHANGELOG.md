### 0.4.0

* enhancements
  * add `cached_alt` and `cached_title` columns to Asset model.

* deprecation
  * Deprecated `Structure.with_scope` in favor of `Structure.with_type`

* backwards incompatible changes
  * Structure model: renamed `kind` column to `structure_type_id` and `position` renamed to `position_type_id`
  * User model: removed `trust_state` column
  * AdminComment model: renamed `author_id` to `user_id`, `author_name` to `user_name`, `user_id` to `resource_user_id`
  * Devise: see `config.clean_up_csrf_token_on_authentication`, `config.secret_key` config options