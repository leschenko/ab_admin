Dir["#{File.dirname(__FILE__)}/*.rb"].sort.each do |path|
  next if File.basename(path) == 'all.rb'
  require "ab_admin/models/validations/#{File.basename(path)}"
end
