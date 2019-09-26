# frozen_string_literal: true

# TODO: Move to the storage service
# rubocop:disable Rails/Output
class PlatformEventProcessor
  # Handle an update to an IAM Credential
  def self.iam_credential(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end

  def self.iam_user_group(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end

  def self.iam_group_policy_join(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end

  def self.iam_user(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end

  def self.tenant(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end

  def self.storage_transfer_map(urn:, event:, data:)
    puts urn
    puts event
    puts data
  end
end
# rubocop:enable Rails/Output
