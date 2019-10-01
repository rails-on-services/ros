# frozen_string_literal: true

class CloudEventSubject
  include ActiveModel::Model

  attr_reader :id, :name

  def initialize(name)
    @id = SecureRandom.uuid
    @name = name
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
