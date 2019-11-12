# frozen_string_literal: true

# ubocop:disable Metrics/BlockLength
after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      next if User.count.positive?

      user = User.create(username: 'Admin', console: true, api: true, time_zone: 'Asia/Singapore',
                         password: 'asdfjkl;')
      User.create(username: 'Microsite', console: false, api: true, time_zone: 'Asia/Singapore')
      # user.locale: 'en-US'
      credential = user.credentials.create
      @created_list.append(type: 'user', owner: user, tenant: tenant, credential: credential,
                           secret: credential.secret_access_key)

      admin_policy = user.policies.create(name: 'Admin Policy')

      actions = [
        {
          name: '*',
          effect: :allow,
          target_resource: "urn:#{Settings.partition_name}:iam::#{tenant.account_id}:*",
          segment: :everything
        },
        {
          name: '*',
          effect: :allow,
          target_resource: "urn:#{Settings.partition_name}:iam::platform:tenant",
          segment: :everything
        },
        {
          name: '*',
          effect: :allow,
          target_resource: "urn:#{Settings.partition_name}:comm::#{tenant.account_id}:*",
          segment: :everything
        },
        {
          name: '*',
          effect: :allow,
          target_resource: "urn:#{Settings.partition_name}:cognito::#{tenant.account_id}:*",
          segment: :everything
        }
      ]

      actions.each do |action|
        admin_policy.actions.create(action)
      end

      # Create a Group
      group_admin = Group.create(name: 'Admin')

      # Attach the Admin Policy to the Group
      group_admin.policies << Policy.first

      # Assign the first User to the Admin Group
      group_admin.users << User.first

      # NOTE: create remainign groups
      Group.create(name: 'Creator')
      Group.create(name: 'Customer Support')
      Group.create(name: 'Manager')
      Group.create(name: 'Viewer')
    end
  end

  # Append newly created credentials to credentials.json in the tmp directory
  FileUtils.mkdir_p(Ros.host_tmp_dir)
  File.open("#{Ros.host_tmp_dir}/credentials.json", 'w') do |f|
    f.puts(@created_list.to_json)
  end
  # Output the contents so that it can be captured by the helm log file when deployed into kubernetes
  STDOUT.puts 'Credentials are next:'
  STDOUT.puts File.read("#{Ros.host_tmp_dir}/credentials.json")
end
# ubocop:enable Metrics/BlockLength
