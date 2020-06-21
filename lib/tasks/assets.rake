require 'ruby-progressbar'

namespace :assets do
  # rake assets:reprocess CLASS=PostImage
  desc 'Refresh carrierwave assets versions by model (CLASS=)'
  task reprocess: :environment do
    name = (ENV['CLASS'] || ENV['class'] || 'Asset').to_s
    klass = name.safe_constantize
    raise "Cannot find a constant with the #{name} specified in the argument string" if klass.nil?

    versions = []
    if ENV['VERSIONS']
      all_versions = klass.uploaders[:data].versions.keys.map(&:to_s)
      versions = ENV['VERSIONS'].split(',').flat_map{|v| all_versions.find_all {|vv| vv =~ Regexp.new("^#{v.gsub('*', '.*')}$") } }.map(&:to_sym).uniq
    end
    puts "Model: #{klass.name}, versions: #{versions.presence || 'ALL'}"

    bar = ProgressBar.create(title: name, total: klass.count, format: '%c of %C - %a %e |%b>>%i| %p%% %t')
    bar.progress_mark = '='

    klass.find_each do |item|
      begin
        item.data.recreate_versions!(*versions)
        bar.increment
      rescue => e
        puts "ERROR recreate_versions for #{name} - #{item.id}: #{e.message}"
      end
    end

    bar.finish
  end
end
