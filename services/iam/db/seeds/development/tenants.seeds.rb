# frozen_string_literal: true

# NOTE: Disabling event logging
logging_mem = Settings.event_logging.enabled
Settings.event_logging.enabled = false
# if 'platform owner' account does not exist then create it and initialize credentials file
owner_root = Root.find_or_create_by(email: 'root@owner.com')

@created_list = []
if owner_root.new_record?
  owner_root.password = 'asdfjkl;'
  owner_root.save

  list = [
    { email: 'root@platform.com', password: 'asdfjkl;', api: true, alias: 'owner' },
    { email: 'root@generic.com', password: 'asdfjkl;', alias: 'generic' },
    { email: 'root@banking.com', password: 'asdfjkl;', alias: 'banking' },
    { email: 'root@telco.com', password: 'asdfjkl;', alias: 'telco' },
    { email: 'root@insurance.com', password: 'asdfjkl;', alias: 'insurance' },
    { email: 'root@retail.com', password: 'asdfjkl;', alias: 'retail' },
    { email: 'root@other.com', password: 'asdfjkl;', alias: 'other' }
  ]

  Tenant.create(schema_name: 'public', name: 'Account 1', alias: 'root', root: owner_root)

  1.upto(7) do |id|
    root_item = list.shift
    alias_name = root_item.delete(:alias)

    schema_name = Tenant.account_id_to_schema(id.to_s * 9)
    root = Root.create!(root_item)

    Tenant.find_or_create_by(root_id: root.id, schema_name: schema_name, alias: alias_name)
    credential = Credential.create(owner: root)
    @created_list.append(type: 'root', owner: root, tenant: root.tenant, credential: credential,
                         secret: credential.secret_access_key)
  end
end

Settings.event_logging.enabled = logging_mem
