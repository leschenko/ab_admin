require 'generator_spec/test_case'

describe AbAdmin::Generators::ResourceGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)
  arguments %w(User)

  before(:all) do
    prepare_destination
    run_generator
  end


  it 'creates a test initializer' do
    assert_file 'config/initializers/test.rb', '# Initializer'
  end
end