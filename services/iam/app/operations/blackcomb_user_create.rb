# frozen_string_literal: true

require 'securerandom'

class BlackcombUserCreate < Ros::ActivityBase
  step :valdidate_root_owner
  failed :invalid_user, Output(:success) => End(:failure)
  step :switch_tenant
  failed :invalid_schema, Output(:success) => End(:failure)
  step :create_or_find_blackcomb_user
  failed :failed_to_create_user

  private

  def valdidate_root_owner(_ctx, params:, **)
    Apartment::Tenant.current == 'public' && params[:current_user].root?
  end

  def invalid_user(_ctx, errors:, **)
    errors.add(:user, 'Not a owner root')
  end

  def switch_tenant(_ctx, params:, **)
    tenant = Tenant.find_by_schema_or_alias(params[:account_id])
    return false unless tenant

    tenant.switch!
    true
  end

  def invalid_schema(_ctx, errors:, **)
    errors.add(:account_id, 'Invalid account id')
  end

  def create_or_find_blackcomb_user(ctx, **)
    ctx[:model] = User.find_or_initialize_by(username: 'blackcomb')

    return true if ctx[:model].persisted?

    password = SecureRandom.hex
    ctx[:model].update(password: password, password_confirmation: password,
                       confirmed_at: Time.zone.today, attached_policies: { AdministratorAccess: 1 })
    ctx[:model].save
  end

  def failed_to_create_user(ctx, model:, **)
    ctx[:errors] = model.errors
  end
end
