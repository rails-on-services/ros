# frozen_string_literal: true

class ChownResult < Cognito::ApplicationRecord
  belongs_to :chown_request
end
