# frozen_string_literal: true

# TODO: Authorize method
# TODO: scope value is the subject's policies; What if the subject's policies change after token issued?
# It could be that every token expires in 10 minutes or something which means that the auth strategy
# would check and then re-issue a token as long as the user is still valid;
# this would update permissions at that point
# or it would need to check if the user has been updated since the token was issued
# def self.issue(iss: Ros::Sdk.service_endpoints['iam'], sub:, scope:)
#   issued_at = Time.now.to_i
#   token = { iss: iss, aud: ['this_domain'], sub: sub, scope: scope, iat: issued_at }
#   token.merge!(exp: issued_at + expires_in) if expires_in = Settings.dig(:jwt, :token_expires_in_seconds)
#   token
# end
module Ros
  class Jwt
    attr_reader :claims, :token

    def initialize(payload)
      if payload.is_a? Hash # From IAM::User, IAM::Root
        @claims = payload.merge(default_payload)
      else # From a bearer token
        @token = payload.gsub('Bearer ', '')
        decode
      end
    end

    def default_payload
      issued_at = Time.now.to_i
      token = (expires_in = Settings.dig(:jwt, :token_expires_in_seconds)) ? { exp: issued_at + expires_in } : {}
      token.merge(iss: iss, aud: aud, iat: issued_at)
    end

    def add_claims(claims = {})
      @claims.merge!(claims.select{ |k, v| k.to_s.in?(valid_claims) })
      self
    end

    def valid_claims; @valid_claims ||= (Settings.dig(:jwt, :valid_claims) || []) end

    # TODO: Set audience from the issuer's domain name
    def aud; Settings.jwt.aud end

    def iss; Settings.jwt.iss end

    def encode
      @token = JWT.encode(claims, encryption_key, alg, { typ: 'JWT' })
    end

    def decode
      @claims = JWT.decode(token, encryption_key, alg).first
    end

    def encryption_key; Settings.jwt.encryption_key end

    def alg; Settings.jwt.alg end
  end
end
