# -*- encoding : utf-8 -*-
Dir["#{File.dirname(__FILE__)}/hooks/*.rb"].sort.each do |path|
  require "ab_admin/hooks/#{File.basename(path, '.rb')}"
end
