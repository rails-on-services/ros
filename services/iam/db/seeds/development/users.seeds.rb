# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      if Policy.count.zero?
        # Add IAM Policies
        Policy.create(name: 'AdministratorAccess')
        Policy.create(name: 'IamUserFullAccess')
        Policy.create(name: 'IamUserReadOnlyAccess')
      end
      next if User.count.positive?

      user = User.create(username: "Admin_#{tenant.id}", console: true, api: true, time_zone: 'Asia/Singapore',
                         password: 'asdfjkl;')
      User.create(username: 'Microsite', console: false, api: true, time_zone: 'Asia/Singapore')
      # user.locale: 'en-US'
      credential = user.credentials.create
      WriteUser.new(owner: user, tenant: tenant, credential: credential).write

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
