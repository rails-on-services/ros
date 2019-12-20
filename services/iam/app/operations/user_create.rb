# frozen_string_literal: true

class UserCreate < Ros::ActivityBase
  step :check_permission
  failed :not_permitted, Output(:success) => End(:failure)
  step :init
  step :initialize_user
  step :skip_confirmation_notification
  step :generate_reset_passowrd_token
  step :save_user
  failed :user_not_created
  step :create_relationships
  step :send_welcome_email

  private

  def check_permission(_ctx, user:, **)
    UserPolicy.new(user, User.new).create?
  end

  def not_permitted(_ctx, errors:, **)
    errors.add(:user, 'not permitted to create a user')
  end

  def init(ctx, params:, **)
    ctx[:relationships] = params.delete(:relationships)
    true
  end

  def initialize_user(ctx, params:, **)
    ctx[:model] = User.new(params)
  end

  def skip_confirmation_notification(_ctx, model:, **)
    model.skip_confirmation_notification!
  end

  def generate_reset_passowrd_token(ctx, model:, **)
    # NOTE: Alternative way is
    # ctx[:reset_password_token] = model.send(:set_reset_password_token)
    # But it saves model
    ctx[:reset_password_token], enc = Devise.token_generator.generate(model.class, :reset_password_token)

    model.reset_password_token   = enc
    model.reset_password_sent_at = Time.now.utc
  end

  def save_user(_ctx, model:, **)
    model.save
  end

  def user_not_created(_ctx, model:, errors:, **)
    errors.add(:user, model.errors.full_messages)
  end

  def create_relationships(_ctx, model:, relationships:, **)
    return true if relationships&.dig(:groups, :data).blank?

    model.groups << Group.where(id: relationships[:groups][:data].pluck(:id)).all
  end

  def send_welcome_email(_ctx, model:, reset_password_token:, **)
    AccountMailer.team_welcome(model, reset_password_token).deliver_later
  end
end
