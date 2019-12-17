# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  default template_path: 'user_mailer',
          from: Settings.smtp.from

  layout 'mailer'

  def confirmation_instructions(resource, devise_token, _opts = {})
    @resource = resource
    @devise_token = devise_token

    if resource.unconfirmed_email.nil?
      @account_name = Tenant.current_tenant&.alias
      @reset_url = user_reset_password_url
      template_name = 'team_welcome'
    else
      @confirmation_url = user_confirmation_url
      template_name = 'confirmation_instructions'
    end

    mail to: resource.email, template_name: template_name
  end

  def reset_password_instructions(resource, devise_token, _opts = {})
    @ip = request.remote_ip
    @resource = resource
    @devise_token = devise_token
    @reset_url = user_reset_password_url

    mail to: resource.email
  end

  private

  def token
    # the token here is whatever we get from devise which can be (at present) an
    # account confirmation token or a password confirmation token
    Ros::Jwt.new(token: @devise_token,
                 account_id: Tenant.current_tenant&.alias,
                 username: @resource.username).encode(:confirmation)
  end

  def user_confirmation_url
    account_url :confirm
  end

  def user_reset_password_url
    account_url :reset
  end

  def account_url(kind)
    base_url + "/password/#{kind}?#{token_name kind}=#{token}"
  end

  def token_name(kind)
    case kind
    when :confirm
      'confirmation_token'
    when :reset
      'reset_password_token'
    else
      raise ArgumentError, "Unknown token type: #{kind}"
    end
  end

  def base_url
    Tenant.current_tenant.properties['base_url'] || 'http://localhost'
  end
end
