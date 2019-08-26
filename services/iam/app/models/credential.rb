# frozen_string_literal: true

class Credential < Iam::ApplicationRecord
  attr_reader :schema_name

  # NOTE: to manually authenticate a password from the console
  # credential.authenticate_secret_access_key(secret_access_key_plaintext)
  # See: https://blog.bigbinary.com/2019/04/23/rails-6-allows-configurable-attribute-name-on-has_secure_password.html
  has_secure_password :secret_access_key, validations: false

  belongs_to :owner, polymorphic: true

  before_validation :generate_values, on: :create

  validates :access_key_id, length: { is: 20 }

  def self.access_key_id_to_schema_name(access_key_id)
    find_by(access_key_id: access_key_id) || new(access_key_id: access_key_id)
  end

  def self.validate(access_key_id, secret_access_key)
    # Root Credentials validation
    # NOTE: Call to this method MUST begin in the 'public' schema
    Apartment::Tenant.switch('public') do
      if credential = find_by(access_key_id: access_key_id)
        return credential.authenticate_secret_access_key(secret_access_key).try(:owner)
      end
    end

    # IAM Credentials validation
    schema_name = new(access_key_id: access_key_id).schema_name
    return unless tenant = Tenant.find_by(schema_name: schema_name)
    tenant.switch do
      break unless credential = find_by(access_key_id: access_key_id)
      credential.authenticate_secret_access_key(secret_access_key).try(:owner)
    end
  end

  def generate_values
    # TODO: Refactor to get from RequestStore
    self.access_key_id = generate_access_key_id
    self.secret_access_key = SecureRandom.urlsafe_base64(40)
  end

  def generate_access_key_id
    owner_type.eql?('Root') ? "A#{(1..19).map { rand(65..90).chr }.join}" : access_key_id_from_schema_name
  end

  def access_key_id_from_schema_name
    schema_name = Apartment::Tenant.current
    account_id = schema_name.remove('_')
    offset = rand(0..6)
    salt = Settings.credential&.salt.to_s.split('')
    key_prefix = "A#{(offset + 65).chr}"
    account_id.split('').each_with_object(key_prefix.split('')) do |v, a|
      a.append (v.to_i + salt.shift.to_i + offset + 65).chr
      a.append (65 + rand(26)).chr
    end.join
  end

  # access_key_id = 'AFJBLNJJFGFRFSOINUHB'
  # if Credential.find_by(access_key_id: access_key_id).try(:schema_name) ||
  # Credential.new(access_key_id: access_key_id).schema_name
  def schema_name
    @schema_name ||= owner_type.eql?('Root') ? owner.tenant.schema_name : schema_name_from_access_key_id
  end

  def schema_name_from_access_key_id
    offset = access_key_id[1].ord - 65
    salt = Settings.credential&.salt.to_s.split('')
    a = access_key_id.last(2).split('')
    b = a.values_at(* a.each_index.select {|i| i.even?})
    b.each_with_object([]) do |char, a|
      a.append (char.ord - salt.shift.to_i - offset - 65).to_s
    end.join.scan(/.{3}/).join('_')
  end

  def self.urn_id; :access_key_id end
end
