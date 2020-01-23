# frozen_string_literal: true

class MessageSend < Ros::ActivityBase
  step :retrieve_message
  failed :message_not_found, Output(:success) => End(:failure)
  step :fetch_message_provider, Output(:success) => Id(:send_message), Output(:failure) => Id(:fetch_tenant_provider)
  step :fetch_tenant_provider, Output(:success) => Id(:send_message), Output(:failure) => Id(:fetch_platform_provider)
  step :fetch_platform_provider
  failed :cannot_provider, Output(:success) => End(:failure)
  step :send_message
  step :update_message_provider_id

  def retrieve_message(ctx, id:, **)
    ctx[:message] = Message.find_by(id: id)
  end

  def message_not_found(_ctx, errors:, id:, **)
    errors.add(:message, "with #{id} not found")
  end

  def fetch_message_provider(ctx, message:, **)
    ctx[:provider] = message.provider
  end

  def fetch_tenant_provider(ctx, message:, **)
    ctx[:provider] = Tenant.find_by(schema_name: Apartment::Tenant.current).default_provider_for(message.channel)
  end

  def fetch_platform_provider(ctx, message:, **)
    ctx[:provider] = Tenant.find_by(schema_name: 'public').default_provider_for(message.channel)
  end

  def cannot_fetch_provider(_ctx, message:, errors:, **)
    errors.add(:provider, "for channel #{message.channel} not found")
  end

  def send_message(ctx, message:, provider:, **)
    ctx[:msg_id] = provider.send(message.channel, message.from, message.to, message.body)
  end

  def update_message_provider_id(ctx, message:, **)
    message.provider_msg_id = ctx[:msg_id]
    message.save
  end
end
