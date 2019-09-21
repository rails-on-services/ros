# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
class EndpointGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_files
    name_cp = name.classify.pluralize
    is_engine = Dir["#{Dir.pwd}/lib/**/engine.rb"].any?
    # for apps the parent_module is blank; for engines the parent_module is a namespace, e.g. 'Iam::'
    # TODO: somehow identify what character string should be removed, e.g. 'ros-'
    parent_module = is_engine ? "#{Dir.pwd.split('/').last.remove('ros-').classify}::" : ''

    # Generate and modify model
    invoke(:model)
    gsub_file("app/models/#{name}.rb", 'ApplicationRecord', "#{parent_module}ApplicationRecord")

    # invoke(:controller)
    # gsub_file("app/controllers/#{plural_name}_controller.rb", 'ApplicationController',
    # "#{parent_module}ApplicationController")

    # Resource
    create_file "app/resources/#{name}_resource.rb", <<~FILE
      # frozen_string_literal: true

      class #{name.classify}Resource < #{parent_module}ApplicationResource
        attributes #{args.reject { |a| a.split(':').last.in? %w[references belongs_to] }.map { |e| ':' + e.split(':').first }.join(', ')}
        has_one #{args.select { |a| a.split(':').last.in? %w[references belongs_to] }.map { |e| ':' + e.split(':').first }.join(', ')}
      end
    FILE

    # Resource spec
    create_file "spec/resources/#{name}_resource_spec.rb", <<~FILE
      # frozen_string_literal: true

      RSpec.describe #{name.classify}Resource, type: :resource do
        let(:#{name}) { create(:#{name}) }
      end
    FILE

    # Policy
    create_file "app/policies/#{name}_policy.rb", <<~FILE
      # frozen_string_literal: true

      class #{name.classify}Policy < #{parent_module}ApplicationPolicy
      end
    FILE

    # Policy spec
    create_file "spec/policies/#{name}_policy_spec.rb", <<~FILE
      # frozen_string_literal: true

      RSpec.describe #{name.classify}Policy, type: :policy do
        let(:#{name}) { create(:#{name}) }
      end
    FILE

    # Controller
    create_file "app/controllers/#{plural_name}_controller.rb", <<~FILE
      # frozen_string_literal: true

      class #{name_cp}Controller < #{parent_module}ApplicationController
      end
    FILE

    # ApiDoc
    create_file "doc/resources/#{name}_resource_doc.rb", <<-FILE
      # frozen_string_literal: true

      class #{name.classify}ResourceDoc < ApplicationDoc
        route_base '#{plural_name}'

        api :index, 'All #{plural_name.capitalize}'
        api :show, 'Single #{name.capitalize}'
        api :create, 'Create #{name.capitalize}'
        api :update, 'Update #{name.capitalize}'
      end
    FILE

    # Route
    insert_into_file 'config/routes.rb', after: "routes.draw do\n" do
      "  jsonapi_resources :#{plural_name}\n"
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
