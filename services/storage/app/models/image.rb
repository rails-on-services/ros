# frozen_string_literal: true

class Image < Storage::ApplicationRecord
  include HasAttachment
  def self.data_type; 'tenants' end
end
