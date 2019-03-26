# frozen_string_literal: true

class Credential < Comm::ApplicationRecord
  belongs_to :provider

  validate :key_name

  attr_encrypted_options.merge!(key: Settings.encryption_key, encode: true, encode_iv: true)
  attr_encrypted :secret

  def key_name
    return if key.in? provider.class.credentials_keys
    errors.add(:key, "must be one of: #{provider.class.credentials_keys.join(' ')}")
  end

  # TODO: Encryption key is externalized
  # def encryption_key
  #   'This is a key that is 256 bits!!'
  # end
end
