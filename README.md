# Simple Drive

This is a Ruby on Rails API project made for the Moyasar Cooperative Training technical task.

The project lets a user save and retrieve data using an ID.

## What the project does

- Save data using `POST /v1/blobs`
- Get saved data using `GET /v1/blobs/:identifier`
- Uses Bearer Token authentication
- Saves data in 3 different ways:
  - Local folder
  - Database
  - S3-compatible storage

The user sends data in Base64 format. The app decodes it, saves it, and returns it as Base64 again when requested.

## Storage backends

The app uses one setting in `.env` to choose where to save the data:

```text
STORAGE_BACKEND=local
```

Possible values are:

```text
local
database
s3
```

The `blobs` table only saves information about each blob, such as its ID, storage type, size, and created time.

The actual data is saved somewhere else:

- Local: inside `storage/blobs`
- Database: inside the `database_blobs` table
- S3: inside an S3 bucket

## Setup

```bash
bundle install
cp .env.example .env
bin/rails db:prepare
bin/rails server
```

## Environment variables

Create a `.env` file and add your own token:

```text
API_TOKEN=your-private-token
STORAGE_BACKEND=local

S3_ENDPOINT=http://localhost:9000
S3_BUCKET=simple-drive
S3_ACCESS_KEY=your-s3-access-key
S3_SECRET_KEY=your-s3-secret-key
S3_REGION=us-east-1
```

## API examples

All requests need this header:

```text
Authorization: Bearer YOUR_API_TOKEN
```

### Save a blob

```bash
curl -X POST http://localhost:3000/v1/blobs \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"id":"my-note","data":"SGVsbG8="}'
```

### Get a blob

```bash
curl http://localhost:3000/v1/blobs/my-note \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

## S3 Storage

For the S3 backend, I used an S3-compatible MinIO server locally.

The app uses Ruby `Net::HTTP` and manually creates AWS Signature Version 4 headers. I did not use an S3 or AWS SDK library.