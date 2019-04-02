# frozen_string_literal: true

namespace :ros do
  desc 'Create OpenAPI V 3.0 docuementation'
  task doc: :environment do
    require 'open_api'
    require Ros::Core::Engine.root.join('doc/application_doc').to_s
    OpenApi::Config.tap do |config|
      config.instance_eval do
        sa = Settings.api_docs
        open_api sa.main, base_doc_classes: [ApplicationDoc]
        info version: sa.info.version, title: sa.info.title, description: sa.info.description
        server sa.server.main, desc: sa.server.desc
        bearer_auth :Authorization
      end
      config.doc_location = ['./doc/**/*_doc.rb']
      config.file_output_path = 'tmp/docs'
      # TODO Remove after PR merge
      config.rails_routes_file = 'tmp/routes.txt'
    end
    # TODO Remove after PR merge
    require 'open3'
    stdin, stdout, stderr = Open3::popen3("rails #{ros_task_prefix}routes")
    File.open('tmp/routes.txt', 'w') { |f| f.write(stdout.read) }
    OpenApi.write_docs
  end
end
