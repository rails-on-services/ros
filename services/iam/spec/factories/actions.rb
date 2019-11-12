# frozen_string_literal: true

FactoryBot.define do
  factory :action do
    trait :admin do
      name { '*' }
      effect { :allow }
      target_resource do
        'urn:' \
        "#{Settings.partition_name}:" \
        'iam:' \
        ':' \
        "#{Tenant.find_by(schema_name: Apartment::Tenant.current).account_id}:" \
        '*'
      end
      segment { :everything }
    end

    trait :tenant do
      name { '*' }
      effect { :allow }
      target_resource { 'urn:perx:iam::platform:tenant' }
      segment { :everything }
    end
  end
end
