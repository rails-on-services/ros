# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address,
             :primary_identifier, :properties, :anonymous
  filter :primary_identifier

  filter :query, apply: lambda { |records, value, _options|
    query_by_non_id_attrs = %w[primary_identifier first_name last_name phone_number email_address]
                            .map { |field| "#{field} ILIKE :non_id_query" }
                            .join(' OR ')

    results = records.where(query_by_non_id_attrs, non_id_query: "%#{value[0]}%")
    results = results.or(records.where(id: value[0])) if /^(\d)+$/.match?(value[0])
    results
  }

  has_many :pools
end
