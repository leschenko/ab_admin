require 'spec_helper'

describe Admin::UsersController, type: :controller do
  login_admin
  describe 'batch actions' do
    let(:users) { create_list(:user, 3) }

    it 'collection batch action' do
      user_ids = users.map(&:id)
      expect(User).to receive(:destroy_collection) do |arg|
        expect(arg.map(&:id)).to match_array user_ids
      end
      allow(User).to receive_message_chain(:batch_actions, :include?).with(:destroy_collection) {true}
      get :batch, by_ids: user_ids, batch_action: 'destroy_collection'
    end

  end
end
