# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address,
             :primary_identifier, :properties, :anonymous, :birthday
  filter :primary_identifier

  filter :query, apply: lambda { |records, value, _options|
    query_by_non_id_attrs = %w[primary_identifier first_name last_name phone_number email_address]
                            .map { |field| "#{field} ILIKE :non_id_query" }
                            .join(' OR ')

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
