# frozen_string_literal: true

class MergeRequestResource < Cognito::ApplicationResource
  attributes :final_user_id, :ids_to_merge
end
