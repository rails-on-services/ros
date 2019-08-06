# frozen_string_literal: true

# TODO: Move to the storage service
class PlatformEventProcessor
  # Handle an update to an IAM Credential
  def self.iam_credential(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end

  def self.iam_user(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end
end
