require "digest"
require "net/http"
require "openssl"
require "uri"

module Storage
  # Saves and retrieves blobs from an S3-compatible server using HTTP only
  class S3Adapter
    SERVICE = "s3"

    # Uploads data to S3 and returns its internal object key
    def store(data)
      storage_key = SecureRandom.uuid
      response = send_request("PUT", storage_key, data)

      unless response.is_a?(Net::HTTPSuccess)
        raise "S3 upload failed: #{response.code} #{response.body}"
      end

      storage_key
    end

    # Downloads data from S3 using its internal object key
    def fetch(storage_key)
      response = send_request("GET", storage_key)

      unless response.is_a?(Net::HTTPSuccess)
        raise ActiveRecord::RecordNotFound
      end

      response.body
    end

    private

    # Sends one signed HTTP request to the S3-compatible server
    def send_request(method, storage_key, body = nil)
      uri = URI("#{endpoint}/#{bucket}/#{storage_key}")
      payload = body || ""
      payload_hash = Digest::SHA256.hexdigest(payload)

      now = Time.now.utc
      amz_date = now.strftime("%Y%m%dT%H%M%SZ")
      date_stamp = now.strftime("%Y%m%d")
      host = host_header(uri)

      # S3 requires these request details to be signed
      canonical_headers = "host:#{host}\n" \
                          "x-amz-content-sha256:#{payload_hash}\n" \
                          "x-amz-date:#{amz_date}\n"
      signed_headers = "host;x-amz-content-sha256;x-amz-date"

      canonical_request = [
        method,
        uri.path,
        "",
        canonical_headers,
        signed_headers,
        payload_hash
      ].join("\n")

      credential_scope = "#{date_stamp}/#{region}/#{SERVICE}/aws4_request"

      string_to_sign = [
        "AWS4-HMAC-SHA256",
        amz_date,
        credential_scope,
        Digest::SHA256.hexdigest(canonical_request)
      ].join("\n")

      signature = OpenSSL::HMAC.hexdigest(
        "sha256",
        signing_key(date_stamp),
        string_to_sign
      )

      authorization = "AWS4-HMAC-SHA256 " \
                      "Credential=#{access_key}/#{credential_scope}, " \
                      "SignedHeaders=#{signed_headers}, " \
                      "Signature=#{signature}"

      request = method == "PUT" ? Net::HTTP::Put.new(uri) : Net::HTTP::Get.new(uri)
      request["Host"] = host
      request["X-Amz-Date"] = amz_date
      request["X-Amz-Content-Sha256"] = payload_hash
      request["Authorization"] = authorization
      request["Content-Type"] = "application/octet-stream" if method == "PUT"
      request.body = body if body

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
    end

    # Creates the AWS Signature Version 4 signing key
    def signing_key(date_stamp)
      key_date = hmac("AWS4#{secret_key}", date_stamp)
      key_region = hmac(key_date, region)
      key_service = hmac(key_region, SERVICE)
      hmac(key_service, "aws4_request")
    end

    def hmac(key, value)
      OpenSSL::HMAC.digest("sha256", key, value)
    end

    def endpoint
      ENV.fetch("S3_ENDPOINT")
    end

    def bucket
      ENV.fetch("S3_BUCKET")
    end

    def access_key
      ENV.fetch("S3_ACCESS_KEY")
    end

    def secret_key
      ENV.fetch("S3_SECRET_KEY")
    end

    def region
      ENV.fetch("S3_REGION")
    end

    def host_header(uri)
      default_port = uri.scheme == "https" ? 443 : 80
      uri.port == default_port ? uri.host : "#{uri.host}:#{uri.port}"
    end
  end
end