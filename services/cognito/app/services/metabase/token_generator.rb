# frozen_string_literal: true

require 'jwt'
module Metabase
  class TokenGenerator
    include ActiveModel::Model
    delegate :minimum_expiry, :maximum_expiry, to: :config
    attr_reader :exp, :payload, :config

    validate :config_validation!
    validates :payload, presence: true
    validates :exp, numericality: {
      less_than_or_equal_to: :maximum_expiry,
      greater_than_or_equal_to: :minimum_expiry
    }, allow_blank: true

    def initialize(payload:, expiry:)
      @config = Metabase::Config.new(secret: Settings.metabase.encryption_key)

      @exp = expiry || config.default_expiry
      @payload = payload.merge(iat: Time.now.to_i, exp: Time.now.to_i + exp)
    end

    def token
      puts "PAYLOAD"
      puts payload
      puts "CONFIG"
      puts config.inspect
      return unless valid?

      @token ||= JWT.encode payload, config.secret, config.sign_algorithm
    end

    private

    def config_validation!
      errors.add(:config, config.errors.messages) unless config.valid?
    end
  end
end
