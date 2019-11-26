# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetabaseCard, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let!(:subject) { create(factory_name) }
  end

  let(:record_one)   { build(factory_name, card_id: rand(1..20), uniq_identifier: subject.uniq_identifier) }
  let(:record_two)   { build(factory_name, card_id: nil) }
  let(:record_three) { build(factory_name, uniq_identifier: nil) }
  let(:record_four)  { build(factory_name, card_id: subject.card_id) }

  it 'is valid if card_id and uniq_identifier present' do
    expect(subject).to be_valid
  end

  it 'is invalid if uniq_identifer is not unique' do
    expect(record_one).to be_invalid
  end

  it 'is invalid if card_id is not unique' do
    expect(record_four).to be_invalid
  end

  it 'is invalid if card_id is nil' do
    expect(record_two).to be_invalid
  end

  it 'is invalid if uniq_identifier is nil' do
    expect(record_three).to be_invalid
  end
end
