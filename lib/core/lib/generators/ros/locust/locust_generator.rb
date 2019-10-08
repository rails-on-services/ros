# frozen_string_literal: true

module Ros
  class LocustGenerator < Rails::Generators::NamedBase
    def create_files
      create_file "../../lib/sre/lib/#{Settings.service.name}/#{name}.py", <<~FILE
        import json
        import pdb
        from locust import HttpLocust, task, TaskSet, TaskSequence

        from base import login

        class #{class_name}(TaskSet):
          def on_start(self):
            login.setup(self)

            self.get_all_#{Settings.service.name}_#{plural_name}()
            self.get_#{Settings.service.name}_#{name}(1)

          @task(2)
          def get_all_#{Settings.service.name}_#{plural_name}(self):
            self.client.get('#{Settings.service.name}/#{plural_name}', headers=self.header )

          @task(2)
          def get_#{Settings.service.name}_#{name}(self, id):
            path = ('#{Settings.service.name}/#{plural_name}/%s' %(id))
            self.client.get(path, headers=self.header )

          @task(2)
          def create_#{Settings.service.name}_#{name}(self, #{create_args}):
            payload = #{payload}
            self.client.get('#{Settings.service.name}/#{plural_name}', data=json.dumps(payload), headers=self.header )

        class #{class_name}Service(HttpLocust):
          task_set = #{class_name}
          # NOTE: Running it locally
          host = 'http://localhost:3000/'
          # NOTE: Running it on uat environment with load-test tag
          # host = 'https://api-load-test.uat.whistler.perxtech.io/'
          max_weight = 500
          min_weight = 500
      FILE
    end

    private

    def values
      OpenStruct.new({
        name: Settings.service.name
      })
    end

    def class_name
      "#{Settings.service.name.classify}#{name.classify}"
    end

    def model
      FactoryBot.build(name.to_sym)
    end

    def required_attributes
      args = %w[id created_at updated_at]
      model.attributes.except(*args)
    end

    def create_args
      associations_attributes = model.attributes.select { |attribute| attribute.end_with?('_id') }
      associations_attributes.keys.join(', ')
    end

    def build_json_string(attributes)
      "{ 'data': { 'type': '#{plural_name}', 'attributes': { #{attributes.join(', ')} } } }"
    end

    def payload
      string_attributes = required_attributes.map do |key, value|
        next "'#{key}': #{value.to_json}" unless key.end_with? '_id'

        "'#{key}': #{key}"
      end

      build_json_string(string_attributes)
    end
  end
end
