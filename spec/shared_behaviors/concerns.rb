require 'spec_helper'

shared_examples_for 'headerable' do
  it { is_expected.to have_one(:header) }
  it { is_expected.to accept_nested_attributes_for(:header) }
  it { is_expected.to respond_to(:default_header) }
end

shared_examples_for 'nested_set' do
  it { is_expected.to have_db_index([:lft, :rgt]) }
  it { is_expected.to have_db_index(:parent_id) }
  it { is_expected.to respond_to(:acts_as_nested_set_options) }
  it { expect(subject.class).to respond_to(:nested_set) }
  it { expect(subject.class).to respond_to(:reversed_nested_set) }
  it { expect(subject.class).to respond_to(:with_depth) }
end
