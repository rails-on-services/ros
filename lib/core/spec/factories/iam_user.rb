# frozen_string_literal: true

FactoryBot.define do
  factory :iam_user, class: Ros::IAM::User do
    id { 1 }
    urn { 'urn:whistler:iam::222222222:user/Admin_2' }
    created_at { '2019-09-13T00:25:26.208Z' }
    updated_at { '2019-09-13T00:25:27.330Z' }
    username { 'Admin_2' }
    api { true }
    console { true }
    time_zone { 'Asia/Singapore' }
    properties { {} }
    display_properties { {} }
    jwt_payload do
      { iss: 'http://iam.localhost:3000', sub: 'urn:whistler:iam::222222222:user/Admin_2', scope: '*' }
    end
    attached_policies { { AdministratorAccess: 1 } }
    attached_actions { {} }
    # end

    # factory :iam_user, class: OpenStruct do
    #   username { Faker::Internet.username }
    #   attached_policies { {} }

    trait :with_administrator_policy do
      attached_policies { { 'AdministratorAccess' => 1 } }
    end
  end
end
