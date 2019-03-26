# frozen_string_literal: true

class WriteUser
  attr_accessor :owner, :tenant, :credential, :fs

  def initialize(owner:, tenant:, credential:, fs:)
    self.owner = owner
    self.tenant = tenant
    self.credential = credential
    self.fs = fs
  end

  def type; owner.class.name.eql?('Root') ? 'email' : 'username' end
  def uid; owner.class.name.eql?('Root') ? owner.email : owner.username end
  def cred_uid; owner.class.name.eql?('Root') ? owner.email.split('@').first : owner.username end

  def login
    puts "Login Payload: user: { #{type}: '#{uid}', password: '#{owner.password}' }, account_id: '#{tenant.account_id}')"
  end

  def credentials
    File.open(fs.creds_file, 'a') do |f|
      f.puts "\n[#{tenant.account_id}_#{cred_uid}]"
      f.puts "#{fs.part_name}_access_key_id=#{credential.access_key_id}"
      f.puts "#{fs.part_name}_secret_access_key=#{credential.secret_access_key}"
    end
  end

  def postman
    name = "#{tenant.schema_name}-#{uid}"
    file_name = "#{fs.postman_dir}/#{name}.json"
    File.write(file_name, "#{postman_config(name).to_json}\n")
  end

  def postman_config(name)
    {
      name: "#{fs.part_name}-#{name}",
      values: [
        { key: "#{fs.part_name}_access_key_id", value: credential.access_key_id },
        { key: "#{fs.part_name}_secret_access_key", value: credential.secret_access_key },
        { key: type, value: uid },
        { key: :password, value: owner.password }
      ]
    }
  end
end

SeedFS = Struct.new(:part_name, :part_dir, :postman_dir, :creds_file)
fs = SeedFS.new(
  Settings.service.partition_name,
  "tmp/#{Settings.service.partition_name}",
  "tmp/#{Settings.service.partition_name}/postman",
  "tmp/#{Settings.service.partition_name}/credentials"
)

# if 'platform owner' account does not exist then create it and initialize credentials file
if Root.find_by(email: 'root@platform.com').nil?
  FileUtils.rm_rf(fs.part_dir)
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

FileUtils.mkdir_p(fs.postman_dir)
FileUtils.touch(fs.creds_file)
absolute_part_dir = "#{Dir.pwd}/#{fs.part_dir}"
Dir.chdir(Dir.home) { FileUtils.ln_s(absolute_part_dir, ".#{fs.part_name}") }

puts "\nUsing Postman:\nConfigs available at: #{fs.postman_dir}"
puts "Using API credentials:\nSet 'Authorization' header value to 'Basic {{#{fs.part_name}_access_key_id}}:{{#{fs.part_name}_secret_access_key}}'"

create_list.each do |account|
  Root.create!(account).tap do |root|
    root.create_tenant(schema_name: Tenant.account_id_to_schema(root.id.to_s * 9), name: "Account #{id}", state: :active)
    credential = Credential.create(owner: root)
    wu = WriteUser.new(owner: root, tenant: root.tenant, credential: credential, fs: fs)
    wu.login
    wu.credentials
    wu.postman
  end
end
