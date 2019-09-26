# frozen_string_literal: true

module Ros
  module TenantPolicyConcern
    extend ActiveSupport::Concern

    included do
      class Scope
        attr_reader :user, :scope

        def initialize(user, scope)
          @user  = user
          @scope = scope
        end

        def resolve
          scope.where(id: user.iam_user.current_tenant.id)
        end
      end
    end
  end
end
