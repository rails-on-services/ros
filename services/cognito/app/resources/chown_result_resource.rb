# frozen_string_literal: true

class ChownResultResource < Cognito::ApplicationResource
  attributes :from_id, :to_id, :status, :service_name, :chown_request_id
  has_one :chown_request
end
