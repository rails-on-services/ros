# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPool, type: :model do
  let(:user) { create(:user) }
  let(:pool) { create(:pool) }

  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let(:subject) { create(factory_name, user_id: user.id, pool_id: pool.id) }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
