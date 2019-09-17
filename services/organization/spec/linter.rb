# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lint' do
  it 'FactoryBot' do
    FactoryBot.lint
  end
end
