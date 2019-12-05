# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address,
             :primary_identifier, :properties, :anonymous, :birthday, :gender
  filter :primary_identifier

  filter :query, apply: lambda { |records, value, _options|
    searchable_columns = ['primary_identifier', 'first_name', 'last_name', 'phone_number', 'email_address',
                          "first_name || ' ' || last_name", "last_name || ' ' || first_name"]
    query_by_non_id_attrs = searchable_columns.map { |field| "#{field} ILIKE :non_id_query" }.join(' OR ')

    results = records.where(query_by_non_id_attrs, non_id_query: "%#{value[0]}%")
    results = results.or(records.where(id: value[0])) if /^(\d)+$/.match?(value[0])
    results
  }

  filter :birth_day, apply: lambda { |records, value, _options|
    records.where("TO_CHAR(birthday, 'DD-MM') = TO_CHAR(DATE(?), 'DD-MM')", value[0])
  }

  filter :birth_month, apply: lambda { |records, value, _options|
    records.where("TO_CHAR(birthday, 'MM') = TO_CHAR(DATE(?), 'MM')", value[0])
  }

  has_many :pools
end
