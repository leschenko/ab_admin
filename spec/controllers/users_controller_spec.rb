require 'spec_helper'

RSpec.describe Admin::UsersController, type: :controller do
  login_admin
  describe 'batch actions' do
    let(:users) { create_list(:user, 3) }

    it 'collection batch action' do
      User.batch_actions = User.batch_actions + [:destroy_collection]
      user_ids = users.map(&:id)
      expect(User).to receive(:destroy_collection) do |arg|
        expect(arg.map(&:id)).to match_array user_ids
      end
      get :batch, params: {by_ids: user_ids, batch_action: 'destroy_collection'}
    end

    after :all do
      User.batch_actions.delete(:destroy_collection)
    end

  end
end
