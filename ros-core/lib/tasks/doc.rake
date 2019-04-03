# frozen_string_literal: true

namespace :ros do
  desc 'Create OpenAPI V 3.0 docuementation'
  task doc: :environment do
    # NOTE: The order of configuration here seems a bit strange, but it is the only way we could get it to work
    require 'open_api'
    Dir.mkdir('tmp') unless Dir.exist?('tmp')
    FileUtils.touch('tmp/routes.txt')
    require 'open3'
    stdin, stdout, stderr = Open3::popen3("rails #{ros_task_prefix}routes")
    File.open('tmp/routes.txt', 'w') { |f| f.write(stdout.read); f.close() }
    OpenApi::Config.tap do |config|
      config.doc_location = ['./doc/**/*_doc.rb']
      config.file_output_path = 'tmp/docs'
      # TODO Remove after PR merge
      config.rails_routes_file = 'tmp/routes.txt'
      require Ros::Core::Engine.root.join('doc/application_doc').to_s
      config.instance_eval do
        sa = Settings.api_docs
        open_api sa.main, base_doc_classes: [ApplicationDoc]
        info version: sa.info.version, title: sa.info.title, description: sa.info.description
        server sa.server.main, desc: sa.server.desc
        bearer_auth :Authorization
      end
    end
    # # TODO Remove after PR merge
    OpenApi.write_docs
  end
end
