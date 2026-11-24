class CreateBlobs < ActiveRecord::Migration[8.1]
  def change
    create_table :blobs do |t|
      t.string :identifier
      t.string :storage_backend
      t.string :storage_key
      t.integer :byte_size

      t.timestamps
    end
  end
end
