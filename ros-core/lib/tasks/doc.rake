# frozen_string_literal: true

namespace :ros do
  desc 'Create OpenAPI V 3.0 docuementation'
  task doc: :environment do
    require 'open_api'
    OpenApi.write_docs
  end
end
