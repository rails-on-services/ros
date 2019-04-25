# frozen_string_literal: true

class TemplateResourceDoc < ApplicationDoc
  route_base 'templates'

  api :index, 'All Templates'
  api :show, 'Single Template'
  api :create, 'Create Template'
  api :update, 'Update Template'
end
