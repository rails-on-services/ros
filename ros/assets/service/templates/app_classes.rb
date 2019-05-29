# frozen_string_literal: true

# ApplicationRecord
inject_into_file "#{@profile.app_dir}/app/models/application_record.rb", after: "ActiveRecord::Base\n" do <<-RUBY
    include Ros::ApplicationRecordConcern
RUBY
end

# ApplicationResource
create_file "#{@profile.app_dir}/app/resources/application_resource.rb" do <<-RUBY
# frozen_string_literal: true

class ApplicationResource < Ros::ApplicationResource
  abstract
end
RUBY
end

# ApplicationPolicy
create_file "#{@profile.app_dir}/app/policies/application_policy.rb" do <<-RUBY
# frozen_string_literal: true

class ApplicationPolicy < Ros::ApplicationPolicy
end
RUBY
end

# ApplicationController
inject_into_file "#{@profile.app_dir}/app/controllers/application_controller.rb", after: "ActionController::API\n" do <<-RUBY
    include Ros::ApplicationControllerConcern
RUBY
end

# ApplicationJob
gsub_file "#{@profile.app_dir}/app/jobs/application_job.rb", 'ActiveJob::Base', 'Ros::ApplicationJob'
