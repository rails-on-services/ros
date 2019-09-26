# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class PolicyGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      create_file "app/policies/#{name}_policy.rb", <<~FILE
        # frozen_string_literal: true

        class #{name.classify}Policy < #{parent_module}ApplicationPolicy
        end
      FILE
    end
  end
end
