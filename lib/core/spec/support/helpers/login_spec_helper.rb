# frozen_string_literal: true

module LoginSpecHelper
  extend ActiveSupport::Concern
  include Warden::Test::Helpers

  included do
    before { Warden.test_mode! }

    after { Warden.test_reset! }
  end

  def login(resource)
    login_as(resource, scope: warden_scope(resource))
  end

  def logout(resource)
    logout(warden_scope(resource))
  end

  private

  def warden_scope(resource)
    resource.class.polymorphic_name.underscore.to_sym
  end
end
