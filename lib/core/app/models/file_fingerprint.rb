# frozen_string_literal: true

class FileFingerprint
  include ActiveModel::Model

  attr_reader :id, :model_name, :model_columns

  def initialize(model_name, model_columns)
    @id = SecureRandom.uuid
    @model_name = model_name
    @model_columns = model_columns
  end

  def readonly?
    true
  end

  def persisted?
    false
  end

  def self.all
    new
  end

  def order
    [self] # following order collect is called on the result so return an array with self
  end

  def count
    1 # count is called for meta
  end
end
