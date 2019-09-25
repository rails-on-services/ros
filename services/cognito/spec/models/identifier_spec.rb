# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  let(:user) { create(:user) }

  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let(:subject) { create(factory_name, user_id: user.id) }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
