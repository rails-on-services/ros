# frozen_string_literal: true

class Campaign < Comm::ApplicationRecord
  has_many :events
  has_many :templates
  belongs_to_resource :owner, polymorphic: true
  belongs_to_resource :cognito_endpoint, class_name: 'Ros::Cognito::Endpoint'
end
