# frozen_string_literal: true

def ros_task_prefix
 @ros_task_prefix ||=  Dir['lib/**/engine.rb'].any? ? 'app:' : ''
end

namespace :ros do
  namespace :db do
		# desc 'Remove all SQLite3 database files'
    # task :rm do
    #   FileUtils.rm Dir.glob('db/*.sqlite3')
    #   FileUtils.rm_rf('spec/dummy/db')
    #   FileUtils.mkdir_p('spec/dummy/db')
    #   FileUtils.touch('spec/dummy/db/seeds.rb')
    # end

    desc 'Clean a database (removes all tenants)'
    task clean: [:environment] do
      Tenant.all.each { |tenant| tenant.destroy }
    end

    namespace :clean do
      desc 'Clean a database and seed it'
      task seed: ["#{ros_task_prefix}ros:db:clean"] do
        Rake::Task["#{ros_task_prefix}db:seed"].invoke
      end
    end

    desc 'Reset a database (drop, create and run migrations)'
    task reset: ["#{ros_task_prefix}db:drop", "#{ros_task_prefix}db:create"] do
      Rake::Task["#{ros_task_prefix}db:migrate"].invoke
    end

    namespace :reset do
      desc 'Reset a database and seed it'
      task seed: ["#{ros_task_prefix}ros:db:reset"] do
# binding.pry
        Rake::Task["#{ros_task_prefix}db:seed"].invoke
      end
    end
  end
end
