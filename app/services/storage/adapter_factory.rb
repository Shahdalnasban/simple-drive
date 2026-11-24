module Storage
  # Chooses the correct storage adapter
  class AdapterFactory
    def self.build(backend)
      case backend
      when "local"
        LocalAdapter.new
      when "database"
        DatabaseAdapter.new
      when "s3"
        S3Adapter.new
      else
        raise ArgumentError, "Unsupported storage backend: #{backend}"
      end
    end
  end
end