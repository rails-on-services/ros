# frozen_string_literal: true

FactoryBot.define do
  factory :provider_aws, class: 'Providers::Aws' do
    name { 'MyString' }
    type { 'Providers::Aws' }
  end
end
