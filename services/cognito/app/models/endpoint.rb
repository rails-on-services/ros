# frozen_string_literal: true

class Endpoint < Cognito::ApplicationRecord
  belongs_to_resource :target, polymorphic: true
end
