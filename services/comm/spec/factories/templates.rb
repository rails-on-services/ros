# frozen_string_literal: true

FactoryBot.define do
  factory :template do
    campaign
    content { "MyText" }
    status { "MyString" }
  end
end
