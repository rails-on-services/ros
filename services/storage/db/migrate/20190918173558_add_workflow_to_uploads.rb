class AddWorkflowToUploads < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE uploads_state AS ENUM ('pending', 'failed', 'done');
    SQL

    add_column :uploads, :workflow_state, :uploads_state, null: false, default: :pending
  end

  def down
    remove_column :uploads, :workflow_state

    execute <<-SQL
      DROP TYPE uploads_state;
    SQL
  end
end
