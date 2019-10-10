# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:pool) { double(Ros::Cognito::Pool, id: 1) }

  before do
    allow(Ros::Cognito::Pool).to receive(:where).and_return [pool]
  end

  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let!(:subject) { create(factory_name) }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
