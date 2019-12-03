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
          if Apartment::Tenant.current == 'public' && user.root?
            scope.all
          else
            current_tenant = Tenant.find_by(schema_name: user.schema_name)
            scope.where(id: current_tenant.id)
          end
        end
      end
    end
  end
end
