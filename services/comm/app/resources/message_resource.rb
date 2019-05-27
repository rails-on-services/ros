# frozen_string_literal: true

class MessageResource < Comm::ApplicationResource
  attributes :from, :to, :body, :provider_id, :owner_id, :owner_type

  filter :owner_id
  filter :owner_type
end
