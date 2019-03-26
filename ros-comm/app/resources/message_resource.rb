# frozen_string_literal: true

class MessageResource < Comm::ApplicationResource
  attributes :from, :to, :body, :provider_id
end
