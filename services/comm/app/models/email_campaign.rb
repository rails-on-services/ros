# frozen_string_literal: true

class EmailCampaign < Comm::ApplicationRecord
  # disable STI
  self.inheritance_column = :_type_disabled
  DEFAULT_TYPE = :regular

  belongs_to :campaign
  belongs_to :audience

  validates :name, :audience, :subject, presence: true
  before_validation :set_defaults


  private

  def set_defaults
    self.type ||= DEFAULT_TYPE
  end

end