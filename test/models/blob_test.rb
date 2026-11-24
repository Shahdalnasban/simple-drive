require "test_helper"

# Tests the validation rules in the Blob model
class BlobTest < ActiveSupport::TestCase
  # Checks that a blob is valid when it has all required information
  test "a blob with valid metadata is valid" do
    blob = Blob.new(
      identifier: "test-blob",
      storage_backend: "local",
      storage_key: "test-key",
      byte_size: 5
    )

    # The blob should pass all validation rules
    assert blob.valid?
  end

  # Checks that an identifier is required
  test "a blob needs an identifier" do
    blob = Blob.new(
      storage_backend: "local",
      storage_key: "test-key",
      byte_size: 5
    )

    # The blob should be invalid because identifier is missing
    assert_not blob.valid?
  end

  # Checks that two blobs cannot have the same identifier
  test "a blob identifier must be unique" do
    # Create the first blob with this identifier
    Blob.create!(
      identifier: "same-id",
      storage_backend: "local",
      storage_key: "first-key",
      byte_size: 5
    )

    # Try to create another blob with the same identifier
    duplicate_blob = Blob.new(
      identifier: "same-id",
      storage_backend: "local",
      storage_key: "second-key",
      byte_size: 5
    )

    # It should be invalid because the identifier already exists
    assert_not duplicate_blob.valid?
  end
end
