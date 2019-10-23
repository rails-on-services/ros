class CreateSftpFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :sftp_files do |t|
      t.string :name
      t.string :key

      t.timestamps
    end
  end
end
