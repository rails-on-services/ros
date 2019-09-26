# frozen_string_literal: true

module Ros
  class PolicySpecGenerator < Rails::Generators::NamedBase
    def create_files
      create_file "spec/policies/#{name}_policy_spec.rb", <<~FILE
        # frozen_string_literal: true

        RSpec.describe #{name.classify}Policy, type: :policy do
          let(:#{name}) { create(:#{name}) }
        end
      FILE
    end
  end
end
