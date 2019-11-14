# frozen_string_literal: true

FactoryBot.define do
  factory :action do
    trait :admin do
      name { '*' }
      effect { :allow }
      target_resource do
        partition_name = Settings.partition_name
        account_id = Tenant.find_by(schema_name: Apartment::Tenant.current).account_id
        "urn:#{partition_name}:iam::#{account_id}:*"
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
