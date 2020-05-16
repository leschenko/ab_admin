require 'ckeditor'

Ckeditor::Utils.module_eval do
  class << self
    def js_replace(dom_id, options = nil)
      options.present? ? "lazyInitCkeditor('#{dom_id}', #{ActiveSupport::JSON.encode(options)});" : "lazyInitCkEditor('#{dom_id}');"
    end
  end
end