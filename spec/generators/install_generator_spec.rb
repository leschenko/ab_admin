require 'spec_helper'
require 'generator_spec/test_case'

describe AbAdmin::Generators::InstallGenerator do
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

  #it 'should copy_views' do
  #end

  it 'should copy_configurations' do
    ['config/initializers/ab_admin.rb', 'config/database.yml', 'db/seeds.rb', 'config/i18n-js.yml',
     'config/logrotate-config', 'config/nginx.conf', 'scripts/unicorn.sh', 'config/unicorn_config.rb'].each do |file|
      assert_file file
    end
  end

  it 'should copy_models' do
    assert_directory 'app/models/defaults'
    assert_directory 'app/uploaders'
    assert_file 'app/models/admin_menu.rb'
  end

  it 'should copy_specs' do
    assert_directory 'spec'
    assert_file 'spec/spec_helper.rb'
    assert_file '.rspec'
  end

end