# frozen_string_literal: true

class Endpoint < Cognito::ApplicationRecord
  api_belongs_to :target, polymorphic: true
  # api_belongs_to :user, class_name: 'Ros::IAM::User'
end
