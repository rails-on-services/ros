# frozen_string_literal: true

class ServicePolicy
  include ActiveModel::Model
  attr_reader :id, :name, :description, :version, :rules

  def initialize(model)
    @id = SecureRandom.uuid
    @name = model['name']
    @description = model['description']
    @version = model['version']
    @rules = model['rules']
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
