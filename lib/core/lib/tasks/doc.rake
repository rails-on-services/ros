# frozen_string_literal: true

# See: https://docs.api.getpostman.com/#331ec7d1-6ffd-450b-996b-022afcb692f8
# See: https://docs.api.getpostman.com/#rate-limits
# Individual resources in your Postman Account is accessible using its unique id (uid).
# The uid is a simple concatenation of the resource owner's user-id and the resource-id.
# For example, a collection's uid is {{owner_id}}-{{collection_id}}

namespace :ros do
  namespace :apidoc do
    desc 'Help'
    task :help do
      puts 'set/export the following ENV vars as needed'
      puts 'PLATFORM__POSTMAN__API_KEY=key'
      puts "PLATFORM__POSTMAN___WORKSPACE='Name of Workspace'"
      puts 'PLATFORM__API_DOCS__SERVER__HOST=http://13.229.71.66:3000'
      puts "PLATFORM__API_DOCS__SERVER__DESC='Server Description'"
      puts 'PLATFORM__API_DOCS__INFO__VERSION=1.0.0'
    end

    desc 'Generate, convert and publish'
    task all: %i[generate convert publish] do
    end

    desc 'Create OpenAPI V 3.0 docuementation'
    task generate: :environment do
      require Ros::Core::Engine.root.join('doc/open_api').to_s
      ActiveRecord::Base.connection.begin_transaction(joinable: false)

      FactoryBot.create(:tenant).switch do
        OpenApi.write_docs
      end
      ActiveRecord::Base.connection.rollback_transaction
    end

    desc 'Convert OpenAPI V 3.0 docuementation to Postman'
    task :convert do
      require Ros::Core::Engine.root.join('doc/postman').to_s
      openapi = Postman::OpenApi.new(file_name: 'ros-api.json', openapi_dir: 'tmp/docs/openapi',
                                     postman_dir: 'tmp/docs/postman')
      openapi.convert_to_postman
    end

    def modify_payload(item)
      if item.is_a? Array
        item.each { |data_item| modify_payload(data_item) }
      elsif item['item']
        modify_payload(item['item'])
      else
        if item['request'].try(:[], 'body').try(:[], 'raw')
          type = JSON.parse(item['request']['body']['raw'])['data']['xyz_type']
          replace_type = type.gsub(/<|>/, '')
          item['request']['body']['raw'].gsub!('xyz_type', 'type')
          item['request']['body']['raw'].gsub!(type, replace_type)
        end
        item['request']['header'].select { |k| k['key'].eql?('Authorization') }.first['value'] = '{{authorization}}'
      end
    end

    desc 'Publish docs to Postman'
    task publish: :environment do
      require Ros::Core::Engine.root.join('doc/postman').to_s
      comm = Postman::Comm.new
      @workspace = Postman::Workspace.new(name: Settings.postman.workspace, comm: comm)
      # @workspace = Postman::Workspace.new(id: '3e6ef171-dccd-4164-ae0d-cc3abbb43bad')
      collection = @workspace.collection(Settings.service.name)
      openapi = Postman::OpenApi.new(file_name: 'ros-api.json', postman_dir: 'tmp/docs/postman')
      data = JSON.parse(openapi.data)

      # Modify Postman JSON to replace the authorization value <String> with the Postman variable {{authorization}}
      data['item'].each { |item| modify_payload(item) }
      payload = @workspace.payload(collection, data)
      @workspace.publish(collection, payload)

      # Invoke service's publish task if it exists
      service_task = "#{ros_task_prefix}ros:#{Settings.service.name}:apidoc:publish"
      Rake::Task[service_task].invoke if Rake::Task.task_defined? service_task
    end
  end
end
