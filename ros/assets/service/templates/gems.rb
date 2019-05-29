# frozen_string_literal: true

gemspec = "#{name}.gemspec"
klass = name.split('-').collect(&:capitalize).join('::')

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

# TODO: remove puma from Gemfile and get a version in here
gem_group :production do
  gem 'puma'
end

unless @profile.is_ros?
  gem 'ros-core', path: "#{@profile.ros_lib_path}/core"
  gem 'ros_sdk', path: "#{@profile.ros_lib_path}/sdk"
  # NOTE: The empty group is to put a separator between the above gems and the ones below.
  # Without this, rails template will put them in alphabetical order which is a problem
  gem_group(:development) do
  end
end

gem "#{@profile.platform_name}-core", path: '../core'
gem "#{@profile.platform_name}_sdk", path: '../sdk'
