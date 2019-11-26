class DropMetabaseCardIdentifierRecordsTable < ActiveRecord::Migration[6.0]
  def change
  	drop_table :metabase_card_identifier_records
  end
end
