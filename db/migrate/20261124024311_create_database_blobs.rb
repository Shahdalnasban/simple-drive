class CreateDatabaseBlobs < ActiveRecord::Migration[8.1]
  def change
    create_table :database_blobs do |t|
      t.string :storage_key
      t.binary :data

      t.timestamps
    end
  end
end
