# LOKI CHUNKS - DATA

resource "aws_s3_bucket" "loki-chunks" {
  bucket = format("%s-%s-loki-chunks", var.project_name, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket_ownership_controls" "loki-chunks" {
  bucket = aws_s3_bucket.loki-chunks.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "loki-chunks" {
  bucket = aws_s3_bucket.loki-chunks.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.loki-chunks
  ]
}

# LOKI ADMIN

resource "aws_s3_bucket" "loki-admin" {
  bucket = format("%s-%s-loki-admin", var.project_name, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket_ownership_controls" "loki-admin" {
  bucket = aws_s3_bucket.loki-admin.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "loki-admin" {
  bucket = aws_s3_bucket.loki-admin.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.loki-admin
  ]
}

## LOKI RULER

resource "aws_s3_bucket" "loki-ruler" {
  bucket = format("%s-%s-loki-ruler", var.project_name, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket_ownership_controls" "loki-ruler" {
  bucket = aws_s3_bucket.loki-ruler.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "loki-ruler" {
  bucket = aws_s3_bucket.loki-ruler.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.loki-ruler
  ]
}