require "fileutils"

module Storage
  # Handles saving and retrieving data from a local folder
  class LocalAdapter
    # Saves real data in a local file and returns its internal filename
    def store(data)
      storage_key = SecureRandom.uuid

      FileUtils.mkdir_p(storage_directory)
      File.binwrite(local_path(storage_key), data)

      storage_key
    end

    # Finds and reads the data using its internal filename
    def fetch(storage_key)
      File.binread(local_path(storage_key))
    end

    private

    # The folder used for locally stored blobs
    def storage_directory
      Rails.root.join("storage", "blobs")
    end

    # Builds the full file path for one blob
    def local_path(storage_key)
      storage_directory.join(storage_key)
    end
  end
end
