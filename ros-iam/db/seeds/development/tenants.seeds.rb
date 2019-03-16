# frozen_string_literal: true

class WriteUser
  attr_accessor :owner, :tenant, :credential

  def initialize(owner:, tenant:, credential:)
    self.owner = owner
    self.tenant = tenant
    self.credential = credential
    login
    credentials
    postman
  end

  def login
    puts "(user: { #{type}: '#{uid}', password: '#{owner.password}' }, account_id: '#{tenant.account_id}')"
  end

  def type; owner.class.name.eql?('Root') ? 'email' : 'username' end
  def uid; owner.class.name.eql?('Root') ? owner.email : owner.username end
  def cred_uid; owner.class.name.eql?('Root') ? owner.email.split('@').first : owner.username end

  def credentials
    File.open("#{Dir.home}/.#{Settings.service.partition_name}/credentials", 'a') do |f|
      f.puts "\n[#{tenant.account_id}_#{cred_uid}]"
      f.puts "#{Settings.service.partition_name}_access_key_id=#{credential.access_key_id}"
      f.puts "#{Settings.service.partition_name}_secret_access_key=#{credential.secret_access_key}"
    end
  end

  def postman
    name = "#{Settings.service.partition_name}-#{tenant.account_id}-#{uid}"
    FileUtils.mkdir_p('tmp/postman')
    file_name = "tmp/postman/#{name}.json"
    File.write(file_name, "#{postman_config(name).to_json}\n")
    puts "Postman config available at: #{file_name}"
  end

  def postman_config(name)
    {
      name: name,
      values: [
        { key: :host, value: 'localhost:3000' },
        { key: "#{Settings.service.partition_name}_access_key_id", value: credential.access_key_id },
        { key: "#{Settings.service.partition_name}_secret_access_key", value: credential.secret_access_key }
      ]
    }
  end
end

# if 'platform owner' account does not exist then create it and initialize credentials file
if Root.find_by(email: 'root@platform.com').nil?
  FileUtils.mkdir_p("#{Dir.home}/.#{Settings.service.partition_name}")
  FileUtils.rm_rf("#{Dir.home}/.#{Settings.service.partition_name}/credentials")
  create_list =  [
    { email: 'root@platform.com', password: 'asdfjkl;', api: true },
    { email: "root@client2.com", password: 'asdfjkl;' }
  ]
else
  id = Tenant.last.id
  create_list =  [
    { email: "root@client#{id + 1}.com", password: 'asdfjkl;' },
    { email: "root@client#{id + 2}.com", password: 'asdfjkl;' }
  ]
end

create_list.each do |account|
  Root.create!(account).tap do |root|
    root.create_tenant(schema_name: Tenant.account_id_to_schema(root.id.to_s * 9), name: "Account #{id}", state: :active)
    credential = Credential.create(owner: root)
    wu = WriteUser.new(owner: root, tenant: root.tenant, credential: credential)
    # show_login('email', root.email, root.password, root.tenant.account_id)
    # write_credentials(credential, root.tenant.account_id, 'root')
  end
end
