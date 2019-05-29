# frozen_string_literal: true

# Modify a new Rails app to become a Ros service
# NOTE: Dir.pwd returns dummy_path while destination_root returns the app path
def source_paths
  ["#{user_path}/templates", "#{service_path}/templates", "#{core_path}/templates",
   service_path, core_path] + Array(super)
end

def user_path; Pathname.new(destination_root).join('../../lib/generators/service') end
def service_path; File.expand_path(File.dirname(__FILE__)) end
def core_path; Pathname.new(File.dirname(__FILE__)).join('../../core/rails') end

# require 'pry'
# binding.pry

require_relative '../../core/rails/profile'
@profile = Profile.new(@app_name || name, self, options.dup)

apply('common.rb')

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

# Create Engine's namespaced classes
if @profile.is_engine?
  template "app/models/%namespaced_name%/application_record.rb"
  template "app/resources/%namespaced_name%/application_resource.rb"
  template "app/policies/%namespaced_name%//application_policy.rb"
  template "app/controllers/%namespaced_name%//application_controller.rb"
  template "app/jobs/%namespaced_name%//application_job.rb"
end

# Modify spec/dummy or app Base Classes
apply('app_classes.rb') if @profile.is_engine?
apply('initializers.rb')
apply('routes.rb')
apply('models.rb')
# Write seed files for tenants, etc
apply('seeds.rb')
apply('rspec.rb')

template 'config/sidekiq.yml'
template 'doc/open_api.yml'

# copy_file 'defaults/files/Procfile', 'Procfile'
# template 'defaults/files/tmuxinator.yml', '.tmuxinator.yml'
