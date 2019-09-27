# frozen_string_literal: true

class OrgResource < Organization::ApplicationResource
  attributes :name, :description, :properties

  has_many :branches

  filter :name, apply: ->(records, value, _options) { records.where('lower(name) like ?', "%#{value[0].downcase}%") }
end
