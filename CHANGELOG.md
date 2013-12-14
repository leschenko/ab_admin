### 0.4.0

* enhancements
  * add `cached_alt` and `cached_title` columns to Asset model.

* deprecation
  * Deprecated `Structure.with_scope` in favor of `Structure.with_type`

* backwards incompatible changes
  * Renamed `kind` column to `structure_type_id` and `position` renamed to `position_type_id` in Structure model
  * Removed `trust_state` column from User model
