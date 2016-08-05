require 'spec_helper'
require 'generator_spec/test_case'

RSpec.describe AbAdmin::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)

  before(:all) do
    prepare_destination

    dir = File.expand_path('../../', __FILE__)
    FileUtils.mkdir_p(File.join(dir, 'tmp/config'))
    FileUtils.copy_file(File.join(dir, 'dummy/config/routes.rb'), File.join(dir, 'tmp/config', 'routes.rb'))
    FileUtils.copy_file(File.join(dir, 'dummy/config/application.rb'), File.join(dir, 'tmp/config', 'application.rb'))

    run_generator
  end

  it 'should copy_configurations' do
    ['config/initializers/ab_admin.rb', 'config/database.yml.sample', 'db/seeds.rb', 'config/i18n-js.yml', 'config/logrotate-config',
     'config/nginx.conf', 'config/robots.txt',
     'config/settings/settings.yml', 'config/settings/settings.local.yml',
     '.gitignore'].each do |file|
      assert_file file
    end
    #puts File.read(File.join(destination_root, 'config/initializers/ab_admin.rb'))
  end

  it 'should copy_models' do
    assert_directory 'app/models/defaults'
    assert_directory 'app/uploaders'
    assert_file 'app/models/admin_menu.rb'
  end

  it 'should copy_helpers' do
    assert_file 'app/helpers/admin/structures_helper.rb'
  end

  it 'should copy_specs' do
    assert_directory 'spec'
    assert_file 'spec/spec_helper.rb'
    assert_file '.rspec'
  end

  it 'should add_routes' do
    assert_file 'config/routes.rb', /devise_for :users, ::AbAdmin::Devise\.config/, /root to:/
  end

  it 'should add autoload_paths' do
    assert_file 'config/application.rb', %r|app/models/defaults|, %r|app/models/ab_admin|
  end

end