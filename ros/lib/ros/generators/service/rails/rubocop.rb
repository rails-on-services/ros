# rubocop/tasks/init.rb

gem_group :development, :test do
  gem 'rubocop', require: false
end

copy_file '.rubocop.yml'

=begin
# Update to remove rubocop warning
gsub_file "#{@profile.app_dir}/config/environments/development.rb", "'tmp/caching-dev.txt'", "'tmp', 'caching-dev.txt'"

# Add Rubocop tasks to Rakefile
# insert_into_file 'Rakefile', before: "require_relative 'config/application'\n" do <<-RUBY
append_to_file 'Rakefile' do <<-RUBY

if Rails.env.development?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

RUBY
end

run 'bundle exec rake rubocop:auto_correct'
git add: '.'
git commit: "-a -m 'Rubocop auto-corrections to initial commit'"
=end
