# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address,
             :primary_identifier, :properties, :anonymous
  filter :primary_identifier

  filter :query, apply: lambda { |records, value, _options|
    filter_fields = %w[primary_identifier first_name last_name email_address]
                    .map { |field| "#{field} ILIKE '%#{value[0]}%'" }
                    .join(' OR ')

    records.where(filter_fields)
  }

  has_many :pools
end
