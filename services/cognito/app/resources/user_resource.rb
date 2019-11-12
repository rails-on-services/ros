# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address,
             :primary_identifier, :properties, :anonymous
  filter :primary_identifier

  filter :query, apply: lambda { |records, value, _options|
    filter_fields = value[0].scan(/\D/).empty? ? query_id(value[0]) : query_non_id_atrributes(value[0])
    records.where(filter_fields)
  }

  has_many :pools

  private

  def query_non_id_atrributes(value)
    %w[primary_identifier first_name last_name email_address]
      .map { |field| "#{field} ILIKE '%#{value}%'" }
      .join(' OR ')
  end

  def query_id(value)
    "id IN (#{value})"
  end
end
