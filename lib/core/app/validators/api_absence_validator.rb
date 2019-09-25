# frozen_string_literal: true

class ApiAbsenceValidator < ActiveModel::EachValidator
  # Make an API call to confirm that the remote record DOES NOT exist
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, 'must be blank') if record.send(attribute)
  end
end
