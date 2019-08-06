# frozen_string_literal: true

# if 'platform owner' account does not exist then create it and initialize credentials file
initialize = Root.find_by(email: 'root@platform.com').nil?

if initialize
  create_list = [
    { email: 'root@platform.com', password: 'asdfjkl;', api: true },
    { email: 'root@client2.com', password: 'asdfjkl;' }
  ]
else
  id = Root.last.id
  create_list = [
    { email: "root@client#{id + 1}.com", password: 'asdfjkl;' },
    { email: "root@client#{id + 2}.com", password: 'asdfjkl;' }
  ]
end

@created_list = []
create_list.each do |account|
  Root.create!(account).tap do |root|
    root.create_tenant(schema_name: Tenant.account_id_to_schema(root.id.to_s * 9)[0..10],
                       name: "Account #{id}", state: :active)
    credential = Credential.create(owner: root)
    @created_list.append({ type: 'root', owner: root, tenant: root.tenant, credential: credential, secret: credential.secret_access_key })
  end
end
