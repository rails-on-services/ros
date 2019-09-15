# frozen_string_literal: true

class Tenant < Iam::ApplicationRecord
  include Ros::TenantConcern

  belongs_to :root

  before_validation :generate_values, on: :create
  validate :fixed_values_unchanged_x, if: :persisted?

  # after_commit :create_service_tenants, on: :create

  def enabled?
    state.eql? 'active'
  end

  def create_service_tenants
    Ros::Sdk.configured_services.each do |name, service|
      next if name.eql? 'iam'

      service::Tenant.create(schema_name: schema_name)
      # TODO: Log a warning if any call fails
    end
  end

  def fixed_values_unchanged_x
    errors.add(:root_id, 'root_id cannot be changed') if root_id_changed?
  end

  def generate_values
    self.state = 'active'
    self.schema_name ||= rand(100_000_000..999_999_999).to_s.scan(/.{3}/).join('_')
  end

  def self.public_schema_endpoints
    %w(/users/sign_in /tenants)
  end
end

  # after_commit :seed_tenant, on: :create, unless: -> { Rails.env.production? }
  # after_create :seed_tenant #, on: :create, unless: -> { Rails.env.production? }


  # def seed_tenant
  #   Action.count
  #   Apartment::Tenant.switch(schema_name) do
  #     service = Service.create(name: 'User')
  #     action = ReadAction.create(service: service, name: 'DescribeUser')

  #     # Create a few Policies
  #     policy_admin = Policy.create(name: 'AdministratorAccess')
  #     policy_user_full = Policy.create(name: 'PerxUserFullAccess')
  #     policy_user_read_only = Policy.create(name: 'PerxUserReadOnlyAccess')

  #     # Attach the Action to the Admin Policy
  #     policy_admin.actions << action

  #     # Create a Group
  #     group_admin = Group.create(name: 'Administrators')

  #     # Attach the Admin Policy to the Group
  #     group_admin.policies << policy_admin

  #     # Create a User
  #     user_admin = User.create(email: 'admin@example.com', password: 'abc123za')

  #     # Assign the User to the Admin Group
  #     group_admin.users << user_admin

  #     # Role.create(name: 'PerxServiceRoleForIAM')
  #     # Role.create(name: 'PerxUserReadOnlyAccess')
  #   end
  # end
