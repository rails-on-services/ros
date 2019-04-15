# frozen_string_literal: true

class RootResource < Iam::ApplicationResource
  attributes :email

  filter :email
  # has_many :credentials
end
