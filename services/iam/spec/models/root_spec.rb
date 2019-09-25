# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Root, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { create(:tenant, root: subject) }
    let!(:subject) { create(factory_name) }
  end
end
