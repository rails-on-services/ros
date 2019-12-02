# frozen_string_literal: true

class Credential < Iam::ApplicationRecord
  # NOTE: to manually authenticate a password from the console
  # credential.authenticate_secret_access_key(secret_access_key_plaintext)
  # See: https://blog.bigbinary.com/2019/04/23/rails-6-allows-configurable-attribute-name-on-has_secure_password.html
  has_secure_password :secret_access_key, validations: false

  belongs_to :owner, polymorphic: true

  before_validation :generate_values, on: :create

  # validates :access_key_id, length: { is: 20 }

  def self.access_key_id_to_schema_name(access_key_id)
    Ros::AccessKey.decode(access_key_id)[:schema_name]
  end

  def self.validate(access_key_id, secret_access_key)
    access_key = to_access_key(access_key_id)
    Apartment::Tenant.switch(access_key[:schema_name]) do
      return unless (credential = find_by(access_key_id: access_key_id))

      credential.authenticate_secret_access_key(secret_access_key).try(:owner)
    end
  end

  def generate_values
    # TODO: Refactor to get from RequestStore
    self.access_key_id = Ros::AccessKey.generate(owner)
    self.secret_access_key = SecureRandom.urlsafe_base64(40)
  end

  def to_access_key
    Ros.access_key(access_key_id)
  end

  def self.urn_id
    :access_key_id
  end
end
