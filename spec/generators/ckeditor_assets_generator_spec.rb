require 'spec_helper'
require 'generator_spec/test_case'

RSpec.describe AbAdmin::Generators::CkeditorAssetsGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)

  before(:all) do
    prepare_destination

    run_generator
  end

  it 'creates a admin resource', slow: true do
    assert_directory 'public/javascripts/ckeditor'
    assert_file 'public/javascripts/ckeditor/init.js', /CKEDITOR/
  end
end