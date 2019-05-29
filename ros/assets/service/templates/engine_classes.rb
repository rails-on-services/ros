# frozen_string_literal: true

# ApplicationRecord
create_file "app/models/#{@profile.service_name}/application_record.rb" do <<-RUBY
# frozen_string_literal: true

module #{@profile.module_name}
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true
  end
end
RUBY
end

# ApplicationResource
create_file "app/resources/#{@profile.service_name}/application_resource.rb" do <<-RUBY
# frozen_string_literal: true

module #{@profile.module_name}
  class ApplicationResource < ::ApplicationResource
    abstract
  end
end
RUBY
end

# ApplicationPolicy
create_file "app/policies/#{@profile.service_name}/application_policy.rb" do <<-RUBY
# frozen_string_literal: true

module #{@profile.module_name}
  class ApplicationPolicy < ::ApplicationPolicy
  end
end
RUBY
end

# ApplicationController
create_file "app/controllers/#{@profile.service_name}/application_controller.rb" do <<-RUBY
# frozen_string_literal: true

module #{@profile.module_name}
  class ApplicationController < ::ApplicationController
  end
end
RUBY
end

# ApplicationJob
create_file "app/jobs/#{@profile.service_name}/application_job.rb" do <<-RUBY
# frozen_string_literal: true

module #{@profile.module_name}
  class ApplicationJob < ::ApplicationJob
  end
end
RUBY
end
