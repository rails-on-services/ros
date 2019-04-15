FactoryBot.define do
  factory :credential do
    provider { nil }
    name { "MyString" }
    encrypted_value { "MyString" }
    encrypted_value_iv { "MyString" }
  end
end
