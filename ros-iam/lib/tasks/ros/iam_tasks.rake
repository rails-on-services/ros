# frozen_string_literal: true

namespace :ros do
  namespace :iam do
    namespace :db do
      desc 'Explaining what the task does'
      task :seed do
        seedbank_root = Seedbank.seeds_root
        Seedbank.seeds_root = File.expand_path('db/seeds', Ros::Iam::Engine.root)
        Seedbank.load_tasks
        Rake::Task["db:seed"].invoke
        Seedbank.seeds_root = seedbank_root 
      end
    end
  end
end
