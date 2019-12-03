# frozen_string_literal: true

# if 'platform owner' account does not exist then create it and initialize credentials file
initialize = Root.find_by(email: 'root@platform.com').nil?

create_list = if initialize
                [
                  { email: 'root@platform.com', password: 'asdfjkl;', api: true, alias: 'owner' },
                  { email: 'root@generic.com', password: 'asdfjkl;', alias: 'generic' },
                  { email: 'root@banking.com', password: 'asdfjkl;', alias: 'banking' },
                  { email: 'root@telco.com', password: 'asdfjkl;', alias: 'telco' },
                  { email: 'root@insurance.com', password: 'asdfjkl;', alias: 'insurance' },
                  { email: 'root@retail.com', password: 'asdfjkl;', alias: 'retail' }
                ]
              else
                # TODO: We don't need it anymore
                # id = Root.last.id
                # create_list = [
                #   { email: "root@client#{id + 1}.com", password: 'asdfjkl;' },
                #   { email: "root@client#{id + 2}.com", password: 'asdfjkl;' }
                # ]
                []
              end
Root.create(email: 'root@owner.com', password: 'asdfjkl;').tap do |root|
  root.create_tenant(schema_name: 'public', name: 'Account 1', alias: 'root')
end

@created_list = []
create_list.each do |account|
  tenant_alias = account.delete(:alias)
  Root.create!(account).tap do |root|
    root.create_tenant(schema_name: Tenant.account_id_to_schema(root.id.to_s * 9)[0..10],
                       name: "Account #{root.id}", state: :active, alias: tenant_alias)
    credential = Credential.create(owner: root)
    @created_list.append(type: 'root', owner: root, tenant: root.tenant, credential: credential,
                         secret: credential.secret_access_key)
  end
end
