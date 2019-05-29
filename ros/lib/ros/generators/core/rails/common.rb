# frozen_string_literal: true

gemspec = "#{@profile.name}.gemspec"
klass = @profile.name.split('-').collect(&:capitalize).join('::')

in_root do
  comment_lines gemspec, 'require '
  gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
  gsub_file gemspec, 'TODO: ', ''
  gsub_file gemspec, '~> 10.0', '~> 12.0'
  comment_lines gemspec, /spec\.homepage/
end

gem 'pry-rails'
gem 'awesome_print'

gem_group :development, :test do
  gem 'brakeman', require: false
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'faker'
end

# Postgres
remove_file "#{@profile.app_dir}/config/database.yml"
@database_prefix = "#{@profile.service_name.tr('-', '_')}"
template 'config/database.yml', "#{@profile.app_dir}/config/database.yml"

create_file 'config/environment.rb'
template 'config/spring.rb'

append_to_file 'README.md' do <<-RUBY

# Documentation
[Rails on Services Guides](https://guides.rails-on-services.org)
RUBY
end
