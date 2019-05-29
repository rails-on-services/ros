# frozen_string_literal: true

create_file 'app/models/tenant.rb' do <<-RUBY
# frozen_string_literal: true

class Tenant < #{@profile.module_string}::ApplicationRecord
  include Ros::TenantConcern
end
RUBY
end
