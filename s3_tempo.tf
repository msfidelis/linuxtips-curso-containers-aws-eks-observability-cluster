resource "aws_s3_bucket" "tempo" {
  bucket = format("%s-%s-tempo", var.project_name, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket_ownership_controls" "tempo" {
  bucket = aws_s3_bucket.tempo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tempo" {
  bucket = aws_s3_bucket.tempo.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.tempo
  ]
}