# frozen_string_literal: true

namespace :ros do
  namespace :organization do
    namespace :db do
      desc 'Load engine seeds'
      task :seed do
        seedbank_root = Seedbank.seeds_root
        Seedbank.seeds_root = File.expand_path('db/seeds', Organization::Engine.root)
        Seedbank.load_tasks
        Rake::Task["db:seed"].invoke
        Seedbank.seeds_root = seedbank_root 
      end
    end
  end
end
