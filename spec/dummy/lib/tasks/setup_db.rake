desc 'Setup dummy db with migrations from ab_admin gem'

task setup_db: ['db:create', :environment] do
  ActiveRecord::Migrator.migrate File.expand_path('../../db/migrate/', Rails.root)
  Rake::Task['db:migrate'].invoke
end

task recreate_db: %w(db:drop setup_db db:seed)