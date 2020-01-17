# frozen_string_literal: true

class MessageProcess < Ros::ActivityBase
  step :create_message
  failed :cannot_create_message

  private

  def create_message(ctx, params:, **)
    ctx[:op_result] = MessageCreate.call(params: params)
    ctx[:op_result].success?
  end

  def cannot_create_message(_ctx, op_result:, errors:, **)
    errors.add(:message, op_result.errors.full_messages.join(', '))
  end
end
