require "base64"

class V1::BlobsController < ApplicationController

  # POST /v1/blobs
  def create
    identifier = params[:id].to_s
    encoded_data = params[:data].to_s

    # Check that the user sent both required values
    if identifier.blank? || encoded_data.blank?
      return render json: { error: "id and data are required" }, status: :bad_request
    end

    # Do not allow the same id twice
    if Blob.exists?(identifier: identifier)
      return render json: { error: "A blob with this id already exists" }, status: :conflict
    end

    # Turn Base64 text back into real data
    binary_data = Base64.strict_decode64(encoded_data)

    # Read STORAGE_BACKEND from .env, such as "local" or "database"
    backend = ENV.fetch("STORAGE_BACKEND", "local")

    # Ask the factory for the correct storage worker
    adapter = Storage::AdapterFactory.build(backend)

    # Ask that worker to save the real data
    storage_key = adapter.store(binary_data)

    # Save metadata only in the blobs table
    blob = Blob.create!(
      identifier: identifier,
      storage_backend: backend,
      storage_key: storage_key,
      byte_size: binary_data.bytesize
    )

    render json: blob_response(blob, encoded_data), status: :created

  rescue ArgumentError
    render json: { error: "data must be valid Base64" }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  # GET /v1/blobs/:identifier
  def show
    # Find blob metadata first
    blob = Blob.find_by!(identifier: params[:identifier])

    # Choose the correct worker based on where this blob was saved
    adapter = Storage::AdapterFactory.build(blob.storage_backend)

    # Ask that worker to retrieve the real data
    binary_data = adapter.fetch(blob.storage_key)

    # Return the data to the user as Base64
    render json: blob_response(blob, Base64.strict_encode64(binary_data))
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Blob not found" }, status: :not_found
  end

  private

  # Builds the JSON response required by the assignment
  def blob_response(blob, encoded_data)
    {
      id: blob.identifier,
      data: encoded_data,
      size: blob.byte_size.to_s,
      created_at: blob.created_at.utc.iso8601
    }
  end
end