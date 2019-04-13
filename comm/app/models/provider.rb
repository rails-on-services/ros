# frozen_string_literal: true

class Provider < Comm::ApplicationRecord
  attr_reader :credentials_hash, :client

  has_many :credentials

  validates :type, presence: true

  def sms; raise NotImplementedError end

  def credentials_hash
    @credentials_hash ||= credentials.each_with_object({}) { |c, h| h[c.key] = c.secret }
  end
end
