# frozen_string_literal: true

namespace :ros do
  namespace :iam do
    namespace :db do
      desc 'Invoke IAM seeds'
      task :seed do
        seedbank_root = Seedbank.seeds_root
        Seedbank.seeds_root = File.expand_path('db/seeds', Ros::Iam::Engine.root)
        Seedbank.load_tasks
        Rake::Task['db:seed'].invoke
        Seedbank.seeds_root = seedbank_root
      end
    end

    namespace :apidoc do
      desc 'Publish docs to Postman'
      task :publish do
        # Process each credentials file previously generated by db:seed
        dir = "#{Ros.host_tmp_dir}/credentials/postman"
        Dir["#{dir}/*.json"].each do |postman_env_file|
          payload = JSON.parse(File.read(postman_env_file))
          environment = @workspace.environment(payload['name'])
          payload = @workspace.payload(environment, payload)
          @workspace.publish(environment, payload)
        end
      end
    end

    namespace :credentials do
      desc 'Display IAM credentials for the current deployment'
      task :show do
        puts "Credentials for #{ENV['PLATFORM__API_DOCS__SERVER__HOST']}"
        path = "#{Ros.host_tmp_dir}/credentials"
        puts File.read("#{path}/cli")
        puts "\n\nPostman\n"
        Dir["#{path}/postman/*"].each do |cred|
          puts File.read(cred)
        end
      end

      task :link do
        path = "#{Ros.host_tmp_dir}/credentials"
        FileUtils.mkdir_p("#{Dir.home}/.#{Settings.partition_name}")
        Dir.chdir("#{Dir.home}/.#{Settings.partition_name}") do
          FileUtils.ln_s("#{path}/cli", 'credentials')
        end
      end
    end
  end
end
