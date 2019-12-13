# frozen_string_literal: true

class PoolResource < Cognito::ApplicationResource
  attributes :name, :properties, :user_count, :system_generated
  has_many :users

  filter :query, apply: lambda { |records, value, _options|
    query_by_id = "pools.id IN (#{value[0]})"
    query_by_non_id_attrs = %w[name]
                            .map { |field| "#{field} ILIKE '%#{value[0]}%'" }
                            .join(' OR ')

    filter_fields = /\D/.match?(value[0]) ? query_by_non_id_attrs : query_by_id
    records.where(filter_fields)
  }

  def self.updatable_fields(context)
    super - %i[user_count]
  end

  def self.creatable_fields(context)
    super - %i[user_count]
  end

  def user_count
    users.size
  end
end
