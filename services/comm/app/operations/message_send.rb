# frozen_string_literal: true

class MessageSend < Ros::ActivityBase
  step :init
  step :retrieve_message
  failed :message_not_found, Output(:success) => End(:failure)
  step :fetch_provider
  failed :cannot_provider, Output(:success) => End(:failure)
  step :send_message
  step :update_message_provider_id

  def init(ctx, **)
    ctx[:providers] = {
      platrorm: Tenant.find_by(schema_name: 'public').provider,
      tenant: Tenant.find_by(schema_name: Apartment::Tenant.current).provider
    }
  end

  def retrieve_message(ctx, id:, **)
    ctx[:message] = Message.find_by(id: id)
  end

  def message_not_found(_ctx, errors:, id:, **)
    errors.add(:message, "with #{id} not found")
  end

  def fetch_provider(ctx, message:, providers:, **)
    ctx[:provider] = message.provider || providers[:tenant] || providers[:platform]
  end

  def cannot_provider(_ctx, errors:, **)
    errors.add(:provider, "for tenant #{Apartment::Tenant.current} not found")
  end

  def send_message(ctx, message:, provider:, **)
    ctx[:msg_id] = provider.send(message.channel, message.from, message.to, message.body)
  end

  def update_message_provider_id(ctx, message:, **)
    message.provider_msg_id = ctx[:msg_id]
    message.save
  end
end
