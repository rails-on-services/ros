# frozen_string_literal: true

class MessageResource < Comm::ApplicationResource
  attributes :from, :to, :body, :provider_id, :owner_id, :owner_type, :channel

  filters :owner_id, :owner_type

  def fetchable_fields
    super + [:provider_msg_id]
  end
end
