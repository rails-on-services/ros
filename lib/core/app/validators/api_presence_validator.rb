# frozen_string_literal: true

class ApiPresenceValidator < ActiveModel::EachValidator
  # Make an API call to confirm that the remote record exists
  # don't check the remote object if presence: false
  def validate_each(record, attribute, _value)
    Rails.logger.debug { "Api validation on #{record.to_json}" }
    return if record.send(attribute)

    Rails.logger.debug { "Api validation FAILED on #{record.to_json}" }
    record.errors.add(attribute, "can't be blank")
  end
end
