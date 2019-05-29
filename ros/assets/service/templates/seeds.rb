# frozen_string_literal: true

# TODO: Create some pundit seeds
# app.append_to_file 'db/seeds/iam_roles.seeds.rb', 'roles.seeds.rb'
# app.append_to_file 'db/seeds/development/users.seeds.rb', 'users.seeds.rb'
# app.append_to_file 'README.md'
# frozen_string_literal: true
# Make a Ros Service Gem
# Make a Ros Service that wraps a Ros Service Gem
# Make a Project Service
# Make a Project Core Gem


create_file "#{options.dummy_path}/db/seeds.rb" if @profile.is_engine?

create_file 'db/seeds/development/tenants.seeds.rb' do <<-RUBY
# frozen_string_literal: true

start_id = (Tenant.last&.id || 0) + 1
(start_id..start_id + 1).each do |id|
  is_even = (id % 2).zero?
  Tenant.create!(schema_name: Tenant.account_id_to_schema(id.to_s * 9))
end
RUBY
end

create_file 'db/seeds/development/data.seeds.rb' do <<-RUBY
# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    is_even = (tenant.id % 2).zero?
    next if tenant.id.eql? 1
    tenant.switch do
    end
  end
end
RUBY
end

# Create a rake task that imports seedback seeds
if @profile.is_engine?
  rake_file = "lib/tasks/ros/#{@profile.service_name}_tasks.rake"
  remove_file(rake_file)
  create_file rake_file do <<-RUBY

# frozen_string_literal: true

namespace :ros do
  namespace :#{@profile.service_name} do
    namespace :db do
      desc 'Load engine seeds'
      task :seed do
        seedbank_root = Seedbank.seeds_root
        Seedbank.seeds_root = File.expand_path('db/seeds', Ros::#{@profile.module_name}::Engine.root)
        Seedbank.load_tasks
        Rake::Task["db:seed"].invoke
        Seedbank.seeds_root = seedbank_root 
      end
    end
  end
end
RUBY
  end
end
