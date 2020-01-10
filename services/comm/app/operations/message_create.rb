# frozen_string_literal: true

class MessageCreate < Ros::ActivityBase
  # step :check_permission
  # failed :not_permitted, Output(:success) => End(:failure)
  step :valid_recipient_and_phone_number
  failed :invalid_recipient_and_phone_number, Output(:success) => End(:failure)
  step :match_recipient_and_phone_number
  failed :mismatched_recipient_and_phone_number, Output(:success) => End(:failure)
  step :valid_recipient
  failed :invalid_recipient, Output(:success) => End(:failure)
  step :valid_send_at
  failed :invalid_send_at, Output(:success) => End(:failure)
  step :setup_message
  failed :invalid_message
  step :save_sms
  step :send_to_provider

  # NOTE: Ensures that if send_at was sent then it is a valid date/datetime
  # If send_at is sent and valid, we store it in context, else we jump
  # to the error track.
  # If send_at is not sent we will not delay the sms sending and instead send
  # it immediately

  def check_permission(_ctx, user:, **)
    MessagePolicy.new(user, Message.new).create?
  end

  def not_permitted(ctx, **)
    ctx[:errors].add(:user, 'not permitted to send message')
  end

  def valid_recipient_and_phone_number(ctx, **)
    ctx[:params][:recipient_id].present? || ctx[:params][:to].present?
  end

  def invalid_recipient_and_phone_number(ctx, **)
    ctx[:errors].add(:recipient, 'or phone number is missing')
  end

  def match_recipient_and_phone_number(ctx, **)
    params = ctx[:params]
    recipient_id = params[:recipient_id]
    to = params[:to]

    if recipient_id.present? && to.present?

      user = Ros::Cognito::User.find(recipient_id).first

      return false unless user.phone_number == to
    end

    true
  end

  def mismatched_recipient_and_phone_number(ctx, **)
    ctx[:errors].add(:recipient, 'and phone number is not matched')
  end

  def valid_recipient(ctx, **)
    params = ctx[:params]
    recipient_id = params[:recipient_id]
    to = params[:to]

    if recipient_id.present? && to.blank?
      user = Ros::Cognito::User.find(recipient_id).first

      return false if user.blank?

      ctx[:params][:to] = user.phone_number
    end

    true
  end

  def invalid_recipient(ctx, **)
    ctx[:errors].add(:recipient, 'is not valid')
  end

  def valid_send_at(ctx, **)
    return true if ctx[:send_at].blank?

    begin
      parsed_send_at = Time.zone.parse(ctx[:send_at])
      return false if parsed_send_at.nil?

      ctx[:send_at] = parsed_send_at
    rescue ArgumentError
      return false
    end

    !ctx[:send_at].nil?
  end

  def invalid_send_at(ctx, **)
    ctx[:errors].add(:send_at, "is not a valid date format (send_at: #{ctx[:send_at]})")
  end

  def setup_message(ctx, params:, **)
    ctx[:model] = Message.new(params)
    ctx[:model].valid?
  end

  def invalid_message(ctx, model:, **)
    ctx[:errors] = model.errors
  end

  def save_sms(_ctx, model:, **)
    model.save
  end

  def send_to_provider(ctx, model:, **)
    if ctx[:send_at].present?
      MessageSendJob.set(wait_until: ctx[:send_at]).perform_later(id: model.id)
    else
      MessageSendJob.perform_now(id: model.id)
    end
  end
end
