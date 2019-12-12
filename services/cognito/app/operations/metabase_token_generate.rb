# frozen_string_literal: true

class MetabaseTokenGenerate < Ros::ActivityBase
  required_params :payload

  step :validate_config
  step :validate_payload
  step :validate_expiry
  step :generate_token
  failed :invalid_params

  def validate_config(ctx, **)
    ctx[:config] = Metabase::Config.new(secret: Settings.metabase.encryption_key)
    ctx[:config].valid?
  end

  def validate_expiry(ctx, expiry:, **)
    ctx[:expiry] = expiry || ctx[:config].default_expiry
    ctx[:expiry] >= ctx[:config].minimum_expiry && ctx[:expiry] <= ctx[:config].maximum_expiry
  end

  def validate_payload(ctx, payload:, **)
    ctx[:payload] = payload.merge(iat: Time.now.to_i, exp: Time.now.to_i + exp)
  end

  def generate_token(ctx, **)
    JWT.encode ctx[:payload], ctx[:config].secret, ctx[:config].sign_algorithm
  end

  def invalid_params(ctx, **)
    ctx[:errors].add(:params, 'are not valid to generate token')
  end
end
