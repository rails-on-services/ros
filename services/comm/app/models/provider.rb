# frozen_string_literal: true

class Provider < Comm::ApplicationRecord
  attr_reader :client

  attr_encrypted_options.merge!(key: Settings.encryption_key, encode: true, encode_iv: true)
  attr_encrypted :credential_1
  attr_encrypted :credential_2
  attr_encrypted :credential_3

  validates :type, presence: true

  def self.services
    []
  end

  def provider_from
    current_tenant.properties.dig(:from) || 'Perx'
  end

  def sms
    raise NotImplementedError
  end
end
