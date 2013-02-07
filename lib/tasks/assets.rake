require 'ruby-progressbar'

namespace :assets do
  desc 'Refresh carrierwave assets versions by model (CLASS=)'
  task :reprocess => :environment do
    name = (ENV['CLASS'] || ENV['class'] || 'Asset').to_s
    klass = name.safe_constantize

    raise "Cannot find a constant with the #{name} specified in the argument string" if klass.nil?

    pbar = ProgressBar.create(:title => name, :total => klass.count, :format => '%c of %C - %a %e |%b>>%i| %p%% %t')
    pbar.progress_mark = '='

    klass.find_each do |item|
      begin
        item.data.recreate_versions!
        pbar.increment
      rescue => e
        puts "ERROR recreate_versions for #{name} - #{item.id}: #{e.message}"
      end
    end

    pbar.finish
  end
end
