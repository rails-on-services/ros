class CreateMetabaseCardIdentifierRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :metabase_card_identifier_records do |t|
      t.integer :card_id
      t.string :uniq_identifier

      t.timestamps
    end
  end
end
