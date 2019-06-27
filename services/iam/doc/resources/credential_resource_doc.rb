# frozen_string_literal: true

class CredentialResourceDoc < ApplicationDoc
  # Comment
  route_base 'credentials'

  api :index, 'All Credentials'
  api :show, 'Single Credential'
  api :create, 'Create Credential'
end
