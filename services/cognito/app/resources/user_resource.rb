# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address,
             :primary_identifier, :properties, :anonymous
  filter :primary_identifier

  filter :query, apply: lambda { |records, value, _options|
    query_by_id = "id IN (#{value[0]})"
    query_by_non_id_attrs = %w[primary_identifier first_name last_name email_address]
                            .map { |field| "#{field} ILIKE '%#{value[0]}%'" }
                            .join(' OR ')

    filter_fields = /\D/.match?(value[0]) ? query_by_non_id_attrs : query_by_id
    records.where(filter_fields)
  }

  has_many :pools
end
