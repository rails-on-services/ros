# frozen_string_literal: true

class Endpoint < Cognito::ApplicationRecord
  belongs_to_resource :target, polymorphic: true
  # api_belongs_to :user, class_name: 'Ros::IAM::User'
end
