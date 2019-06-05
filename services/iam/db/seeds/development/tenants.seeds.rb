# frozen_string_literal: true

class WriteUser
  attr_accessor :owner, :tenant, :credential

  def self.initialize
    FileUtils.rm_rf(write_dir)
    FileUtils.mkdir_p("#{write_dir}/postman")
  end

  def initialize(owner:, tenant:, credential:)
    self.owner = owner
    self.tenant = tenant
    self.credential = credential
  end

  def self.write_dir; "#{Ros.host_tmp_dir}/credentials" end
  def write_dir; self.class.write_dir end

  def type; owner.class.name.eql?('Root') ? 'email' : 'username' end
  def uid; owner.class.name.eql?('Root') ? owner.email : owner.username end
  def cred_uid; owner.class.name.eql?('Root') ? owner.email.split('@').first : owner.username end
  def part_name; Settings.partition_name end

  def write; login; credentials; postman end

  def login
    puts "Login Payload: user: { #{type}: '#{uid}', password: '#{owner.password}' }, account_id: '#{tenant.account_id}')"
  end

  def credentials
    File.open("#{write_dir}/cli", 'a') do |f|
      f.puts "\n[#{tenant.account_id}_#{cred_uid}]"
      f.puts "#{part_name}_access_key_id=#{credential.access_key_id}"
      f.puts "#{part_name}_secret_access_key=#{credential.secret_access_key}"
    end
  end

  def postman
    name = "#{tenant.schema_name}-#{uid}"
    file_name = "#{write_dir}/postman/#{name}.json"
    File.write(file_name, "#{postman_config(name).to_json}\n")
  end

  def postman_config(name)
    {
      name: "#{part_name}-#{name}",
      values: [
        { key: :authorization, value: "Basic #{credential.access_key_id }:#{credential.secret_access_key}" },
        { key: type, value: uid },
        { key: :password, value: owner.password }
      ]
    }
  end
end

# if 'platform owner' account does not exist then create it and initialize credentials file
initialize = Root.find_by(email: 'root@platform.com').nil?
if initialize
  WriteUser.initialize
  create_list = [
    { email: 'root@platform.com', password: 'asdfjkl;', api: true },
    { email: "root@client2.com", password: 'asdfjkl;' }
  ]
else
  id = Tenant.last.id
  create_list = [
    { email: "root@client#{id + 1}.com", password: 'asdfjkl;' },
    { email: "root@client#{id + 2}.com", password: 'asdfjkl;' }
  ]
end

create_list.each do |account|
  Root.create!(account).tap do |root|
    root.create_tenant(schema_name: Tenant.account_id_to_schema(root.id.to_s * 9), name: "Account #{id}", state: :active)
    credential = Credential.create(owner: root)
    WriteUser.new(owner: root, tenant: root.tenant, credential: credential).write
  end
end
