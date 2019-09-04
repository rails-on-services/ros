class ApplicationRecord < ActiveRecord::Base
    include Ros::ApplicationRecordConcern
  self.abstract_class = true
end
