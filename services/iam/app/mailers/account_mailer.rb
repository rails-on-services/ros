# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  default template_path: 'user_mailer',
          from: Settings.smtp.from

  layout 'mailer'

  def confirmation_instructions(resource, devise_token, _opts = {})
    @resource = resource
    @devise_token = devise_token
    @confirmation_url = user_confirmation_url

    mail to: resource.email
  end

  def reset_password_instructions(resource, devise_token, _opts = {})
    @resource = resource
    @devise_token = devise_token
    @reset_url = user_reset_password_url

    mail to: resource.email
  end

  private

  def token
    Ros::Jwt.new(token: @devise_token,
                 account_id: Tenant.current_tenant&.alias,
                 username: @resource.username).encode
  end

  def user_confirmation_url
    account_url :account
  end

  def user_reset_password_url
    account_url :password
  end

  def account_url(kind)
    base_url + "/confirm/#{kind}?#{token_name kind}=#{token}"
  end

  def token_name(kind)
    case kind
    when :account
      'confirmation_token'
    when :password
      'reset_password_token'
    else
      raise ArgumentError, "Unknown token type: #{kind}"
    end
  end

  def base_url
    Settings.fe&.base_url || 'http://localhost'
  end
end
