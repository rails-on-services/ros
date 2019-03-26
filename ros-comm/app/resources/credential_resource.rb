# frozen_string_literal: true

class CredentialResource < Comm::ApplicationResource
  attributes :key
  has_one :provider

  def fetchable_fields
    # TODO: implement access_attributes to an IAM permission
    # above = context[:user].policies.each_with_object([]) do { |p, a| a << access_attributes[p] }
    # super + above
    return super + %i(secret) if context[:user].class.name.demodulize.eql? 'Root'
    super
  end

  def policy_fetchable_fields
    {
      'AdministratorAccess' => %i(secret)
    }
  end
end
