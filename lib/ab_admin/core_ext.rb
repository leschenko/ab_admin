Dir["#{File.dirname(__FILE__)}/core_ext/*.rb"].sort.each do |path|
  require "ab_admin/core_ext/#{File.basename(path)}"
end
