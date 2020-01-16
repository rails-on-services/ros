# frozen_string_literal: true

class MessageProcess < Ros::ActivityBase
  step :create_message

  private

  def create_message(_ctx, params:, **)
    MessageCreate.call(params: params)
  end
end
