require 'spec_helper'
require 'generator_spec/test_case'

describe AbAdmin::Generators::ModelGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)
  #arguments %w(Structure)
  arguments %w(Product)

  before(:all) do
    AbAdmin::AbstractResource.descendants.each { |c| Object.send(:remove_const, c.name.to_sym) rescue false }

    prepare_destination

    dir = File.expand_path('../../', __FILE__)
    FileUtils.mkdir_p(File.join(dir, 'tmp/app/models'))
    FileUtils.copy_file(File.join(dir, 'dummy/app/models/admin_menu.rb'), File.join(dir, 'tmp/app/models', 'admin_menu.rb'))

    run_generator
  end

  it 'creates a admin dsl resource' do
    #puts File.read(File.join(destination_root, 'app/models/ab_admin/ab_admin_structure.rb'))
    #puts File.read(File.join(destination_root, 'app/models/ab_admin/ab_admin_product.rb'))
    assert_file 'app/models/admin_menu.rb', /model Product/

    assert_file 'app/models/ab_admin/ab_admin_product.rb', /AbAdminProduct/, /table do/, /field :name, sortable: false/,
                /search do/, /locale_tabs do/, /field :picture, as: :uploader/, /field :map, as: :map/
  end

end
