require 'spec_helper'
require 'generator_spec/test_case'

describe AbAdmin::Generators::ResourceGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)
  arguments %w(Header)

  before(:all) do
    prepare_destination
    run_generator
  end

  it 'creates a admin resource' do
    assert_file 'app/controllers/admin/headers_controller.rb', /HeadersController/

    assert_file 'app/views/admin/headers/_form.html.slim',
                /admin_form_for @header/, /f\.locale_tabs/, /f\.input :headerable_type/, /f\.save_buttons/
    assert_file 'app/views/admin/headers/_table.html.slim',
                /table/, /collection\.each/, /batch_action_item/, /td/, /item_index_actions/
    assert_file 'app/views/admin/headers/_search_form.html.slim',
                /f\.input :translations_title, :label => ha\(:title\)/, /f\.input :created_at/
    assert_file 'app/helpers/admin/headers_helper.rb', /Admin::HeadersHelper/
  end

end