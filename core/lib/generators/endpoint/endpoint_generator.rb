# frozen_string_literal: true

class EndpointGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_files
    is_engine = Dir["#{Dir.pwd}/lib/**/engine.rb"].any?
    # for apps the parent_module is blank; for engines the parent_module is a namespace, e.g. 'Iam::'
    # TODO: somehow identify what character string should be removed, e.g. 'ros-'
    parent_module = is_engine ? "#{Dir.pwd.split('/').last.remove('ros-').classify}::" : ''

    # Generate and modify model
    invoke(:model)
    gsub_file("app/models/#{name}.rb", 'ApplicationRecord', "#{parent_module}ApplicationRecord")

    # invoke(:controller)
    # gsub_file("app/controllers/#{plural_name}_controller.rb", 'ApplicationController', "#{parent_module}ApplicationController")

    # Create resource
    create_file "app/resources/#{name}_resource.rb", <<-FILE
# frozen_string_literal: true

class #{name.classify}Resource < #{parent_module}ApplicationResource
  attributes #{args.reject { |a| a.split(':').last.in? %w(references belongs_to) }.map { |e| ':' + e.split(':').first }.join(', ')}
  has_one #{args.select { |a| a.split(':').last.in? %w(references belongs_to) }.map { |e| ':' + e.split(':').first }.join(', ')}
end
    FILE

    # Create policy
    create_file "app/policies/#{name}_policy.rb", <<-FILE
# frozen_string_literal: true

class #{name.classify}Policy < #{parent_module}ApplicationPolicy
end
    FILE

    # Create controller
    create_file "app/controllers/#{plural_name}_controller.rb", <<-FILE
# frozen_string_literal: true

class #{name.classify.pluralize}Controller < #{parent_module}ApplicationController
end
    FILE

    # Add route
    insert_into_file 'config/routes.rb', after: "routes.draw do\n" do
 "  jsonapi_resources :#{plural_name}\n"
    end

  end
end
