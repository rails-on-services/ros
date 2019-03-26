# frozen_string_literal: true

after 'development:tenants' do

# TODO: This is not at all DRY
fs = SeedFS.new(
  Settings.service.partition_name,
  "tmp/#{Settings.service.partition_name}",
  "tmp/#{Settings.service.partition_name}/postman",
  "tmp/#{Settings.service.partition_name}/credentials"
)

  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1
    tenant.switch do
      if Policy.count.zero?
        # Add IAM Policies
        policy_admin = Policy.create(name: 'AdministratorAccess')
        policy_user_full = Policy.create(name: 'IamUserFullAccess')
        policy_user_read_only = Policy.create(name: 'IamUserReadOnlyAccess')
      end
      next if User.count.positive?
      user = User.create(username: "Admin_#{tenant.id}", password: 'asdfjkl;', console: true, api: true, time_zone: 'Asia/Singapore')
      User.create(username: 'Microsite', console: false, api: true, time_zone: 'Asia/Singapore')
      # user.locale: 'en-US'
      credential = user.credentials.create
      wu = WriteUser.new(owner: user, tenant: tenant, credential: credential, fs: fs)
      wu.login
      wu.credentials
      wu.postman

      # Create a Group
      group_admin = Group.create(name: 'Administrators')

      # Attach the Admin Policy to the Group
      group_admin.policies << Policy.first

      # Assign the first User to the Admin Group
      group_admin.users << User.first

      # Role.create(name: 'PerxServiceRoleForIAM')
      # Role.create(name: 'PerxUserReadOnlyAccess')
    end
  end
end
