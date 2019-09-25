# frozen_string_literal: true

module Metabase
  class Config
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :sign_algorithm, :string, default: 'HS256'
    attribute :default_expiry, :integer, default: 86_400
    attribute :minimum_expiry, :integer, default: 3_600
    attribute :maximum_expiry, :integer, default: 2_592_000
    attribute :secret, :string

    validates :secret, presence: { message: 'Metabase secret is misconfigured or missing' }
  end
end
