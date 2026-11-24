module Storage
  # Handles saving and retrieving real data from the database
  class DatabaseAdapter

    # Saves the real data in database_blobs
    # Returns a hidden key so we can find it later
    def store(data)
      storage_key = SecureRandom.uuid

      DatabaseBlob.create!(
        storage_key: storage_key,
        data: data
      )

      storage_key
    end

    # Finds the saved data by its hidden key
    def fetch(storage_key)
      DatabaseBlob.find_by!(storage_key: storage_key).data
    end
  end
end