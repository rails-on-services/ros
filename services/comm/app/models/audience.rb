# frozen_string_literal: true

class Audience < Comm::ApplicationRecord
  DEFAULT_LANGUAGE = :en
  DEFAULT_REMINDER = 'You are receiving this email, because you subscribed our product.'

  belongs_to :campaign

  validates :name, :from_name, :from_email, presence: true
  before_validation :set_defaults

  private

  def set_defaults
    self.language ||= DEFAULT_LANGUAGE
    self.reminder ||= DEFAULT_REMINDER
  end
end
