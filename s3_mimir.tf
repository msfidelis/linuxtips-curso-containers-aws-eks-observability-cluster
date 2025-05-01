# Mimir

resource "aws_s3_bucket" "mimir" {
  bucket = format("%s-%s-mimir", var.project_name, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket_ownership_controls" "mimir" {
  bucket = aws_s3_bucket.mimir.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "mimir" {
  bucket = aws_s3_bucket.mimir.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.mimir
  ]
}

# Ruler 

resource "aws_s3_bucket" "mimir_ruler" {
  bucket = format("%s-%s-mimir-ruler", var.project_name, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket_ownership_controls" "mimir_ruler" {
  bucket = aws_s3_bucket.mimir_ruler.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "mimir_ruler" {
  bucket = aws_s3_bucket.mimir_ruler.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.mimir_ruler
  ]
}