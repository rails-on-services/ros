# frozen_string_literal: true

class MessageResource < Comm::ApplicationResource
  attributes :from, :to, :body, :provider_id, :owner_id, :owner_type, :channel

  filters :owner_id, :owner_type

  filter :to, apply: lambda {|records, value, _options|
    records.sent_to(value[0])
  }

  filter :user_id, apply: lambda { |records, value, _options|
    user = Ros::Cognito::User.where(id: value[0]).first

    return records.none if user.nil?

    records.sent_to(user.phone_number)
  }

  def fetchable_fields
    super + [:provider_msg_id]
  end
end
