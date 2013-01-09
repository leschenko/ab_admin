require 'ruby-progressbar'

namespace :assets do
  desc 'Refresh carrierwave assets versions by model (CLASS=)'
  task :reprocess => :environment do
    name = (ENV['CLASS'] || ENV['class'] || 'Asset').to_s
    klass = name.safe_constantize

    raise "Cannot find a constant with the #{name} specified in the argument string" if klass.nil?

    pbar = ProgressBar.create(:title => name, :total => klass.count, :format => '%a |%b>>%i| %p%% %t')
    pbar.progress_mark = '='

    index = 0

    klass.find_each do |item|
      begin
        item.data.recreate_versions!
        index += 1
        pbar.progress = index
      rescue => e
        puts "ERROR recreate_versions for #{name} - #{item.id}: #{e.message}"
      end
    end

    pbar.finish
  end
end
