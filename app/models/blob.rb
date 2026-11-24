class Blob < ApplicationRecord
  validates :identifier, presence: true, uniqueness: true
  validates :storage_backend, presence: true
  validates :storage_key, presence: true
  validates :byte_size, presence: true, numericality: { greater_than_or_equal_to: 0 }
end