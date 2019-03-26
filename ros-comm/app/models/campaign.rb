# frozen_string_literal: true

class Campaign < Comm::ApplicationRecord
  has_many :events
  has_many :templates
  api_belongs_to :owner, polymorphic: true
  api_belongs_to :cognito_endpoint, class_name: 'Ros::Cognito::Endpoint'
end
