class DatabaseBlob < ApplicationRecord
  validates :storage_key, presence: true, uniqueness: true
  validates :data, presence: true
end
