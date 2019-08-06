# frozen_string_literal: true

class TransferMap < Storage::ApplicationRecord
  has_many :column_maps

  def self.match(columns_to_match)
    all.each do |tmap|
      columns = tmap.column_maps.pluck(:user_name).sort
      break tmap if columns == columns_to_match
    end
  end
end
