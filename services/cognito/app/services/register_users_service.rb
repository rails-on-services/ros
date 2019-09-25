# frozen_string_literal: true

class RegisterUsersService
  attr_reader :provider, :logger, :tenant

  class InvalidTenant < StandardError
  end
  class InvalidProvider < StandardError
  end

  def initialize(provider:, tenant:, logger: Rails.logger)
    @provider = provider
    @tenant = tenant
    @logger = logger
  end

  # f = CSV.parse(File.read(Rails.root.join('tmp', 'users.csv')), headers:true)
  # provider = f.map(&:to_h)
  def register!
    raise InvalidTenant, "Tenant: #{tenant} is not valid" unless tenant.respond_to? :schema_name
    raise InvalidProvider, "Provider class: #{provider.class} should respond to :each" unless provider.respond_to? :each

    provider.each do |attributes|
      user = User.new(attributes)
      user.save!

      confirm_user! user
    end
  end

  private

  def confirm_user!(user)
    return unless user.persisted?
    return unless tenant.requires_user_confirmation?

    if user&.email.blank?
      logger.info("Can't notify User: #{user.attributes}. Invalid email")
      return
    end
    user.send_confirmation_instructions
  end
end
