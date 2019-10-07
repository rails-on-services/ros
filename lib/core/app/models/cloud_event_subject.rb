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
end
