# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address,
             :primary_identifier, :properties, :anonymous
  filter :primary_identifier

  filter :query, apply: lambda { |records, value, _options|
    query_by_id = 'users.id IN (:id_query)'
    query_by_non_id_attrs = %w[primary_identifier first_name last_name phone_number email_address]
                            .map { |field| "#{field} ILIKE :non_id_query" }
                            .join(' OR ')

    filter_fields = "#{query_by_id} OR #{query_by_non_id_attrs}"
    records.where(filter_fields, id_query: value[0].to_i, non_id_query: "%#{value[0]}%")
  }

  has_many :pools
end
