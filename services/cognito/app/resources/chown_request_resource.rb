# frozen_string_literal: true

class ChownRequestResource < Cognito::ApplicationResource
  attributes :from_ids, :to_id
end
