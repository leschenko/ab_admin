#
# ***** IMPORTANT *****
#
# This file requires hook files with some monkeypatching staff and it is not required by default.
# Please, read code and comments before usage.
#
Dir["#{File.dirname(__FILE__)}/hooks/*.rb"].sort.each do |path|
  require "ab_admin/hooks/#{File.basename(path, '.rb')}"
end

ActiveSupport::XmlMini.backend = 'Nokogiri'

InheritedResources.flash_keys = Responders::FlashResponder.flash_keys = AbAdmin.flash_keys
Responders::FlashResponder.namespace_lookup = true

::SimpleForm.wrapper_mappings ||= {}
::SimpleForm.wrapper_mappings[:uploader] = AbAdmin::Views::ContentOnlyWrapper.instance

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
