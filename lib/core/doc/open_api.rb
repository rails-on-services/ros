# frozen_string_literal: true

# Configuration and setup
require 'open_api'

# NOTE: The order of configuration here seems a bit strange, but it is the only way we could get it to work
# TODO: Fix after PR merge and gem release
# Write Rails routes to a temp file
FileUtils.mkdir_p('tmp')
FileUtils.touch('tmp/routes.txt')
require 'open3'
ros_task_prefix = Dir['lib/**/engine.rb'].any? ? 'app:' : ''
_stdin, stdout, _stderr = Open3.popen3("rails #{ros_task_prefix}routes")
File.open('tmp/routes.txt', 'w') do |f|
  f.write(stdout.read)
  f.close
end

# Configure the gem
OpenApi::Config.tap do |config|
  config.doc_location = ['./doc/**/*_doc.rb']
  config.file_output_path = 'tmp/docs/openapi'
  config.rails_routes_file = 'tmp/routes.txt'
  config.default_run_dry = true
  yaml = YAML.load_file('doc/open_api.yml')['api_docs']
  require Ros::Core::Engine.root.join('doc/controllers/application_doc').to_s
  config.instance_eval do
    open_api Settings.api_docs.name, base_doc_classes: [ApplicationDoc]
    info version: yaml['info']['version'], title: Settings.service.name, description: yaml['info']['description']
    server "#{Settings.api_docs.server.host}/#{Settings.service.name}", desc: yaml['server']['description']
    bearer_auth :Authorization
  end
end
