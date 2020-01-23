# frozen_string_literal: true

class RootResource < Iam::ApplicationResource
  attributes :email, :jwt_payload, :password
  attributes :attached_policies, :attached_actions

  has_many :credentials

  filter :email

  def attached_policies; {} end

  def attached_actions; {} end
end
