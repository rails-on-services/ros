# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(user, User) }
  let(:iam_user) { create(:iam_user, :with_administrator_policy) }
  let(:cognito_user_id) { nil }
  let(:params) { {} }
  let(:policy_user) { PolicyUser.new(iam_user, cognito_user_id, params) }
  let(:existing_users) { create_list :user, 2 }

  before do
    existing_users
  end

  describe 'Scope' do
    let(:scope) { Pundit.policy_scope!(policy_user, User) }

    context 'admin iam user' do
      it 'returns all users' do
        expect(scope.to_a).to match_array(existing_users)
      end
    end

    context 'cognito user' do
      let(:cognito_user) { existing_users.first }
      let(:cognito_user_id) { cognito_user.id }

      it 'returns array with only cognito user' do
        expect(scope.to_a).to match_array([cognito_user])
      end
    end
  end
end
