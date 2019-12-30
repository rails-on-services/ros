# frozen_string_literal: true

class PoolResource < Cognito::ApplicationResource
  attributes :name, :properties, :user_count, :system_generated
  has_many :users

  filter :query, apply: lambda { |records, value, _options|
    query_by_id = 'pools.id IN (:id_query)'
    query_by_non_id_attrs = %w[name]
                            .map { |field| "#{field} ILIKE :ilike_query" }
                            .join(' OR ')

    filter_fields = /^\d+$/.match?(value[0]) ? query_by_id : query_by_non_id_attrs
    records.where(filter_fields, id_query: value[0], ilike_query: "%#{value[0]}%")
  }

  filter :system_generated, apply: lambda { |records, value, _options|
    records.where('system_generated = ?', value[0] == 'true')
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
