# frozen_string_literal: true

class CloudEventSubject
  include ActiveModel::Model

  attr_reader :id, :model_name

  def initialize(model_name)
    @id = SecureRandom.uuid
    @model_name = model_name
  end

  def readonly?
    true
  end

  def persisted?
    false
  end

  # Not sure if these are important now
  # def self.all
  #   new
  # end

  # def order
  #   [self] # following order collect is called on the result so return an array with self
  # end

  # def count
  #   1 # count is called for meta
  # end
end
