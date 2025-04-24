data "aws_iam_policy_document" "loki_role" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "loki_role" {
  assume_role_policy = data.aws_iam_policy_document.loki_role.json
  name               = format("%s-loki", var.project_name)
}

data "aws_iam_policy_document" "loki_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "s3:*",
    ]

    resources = [
      format("%s/*", aws_s3_bucket.loki-chunks.arn),
      format("%s/*", aws_s3_bucket.loki-admin.arn),
      format("%s/*", aws_s3_bucket.loki-ruler.arn),
      aws_s3_bucket.loki-chunks.arn,
      aws_s3_bucket.loki-admin.arn,
      aws_s3_bucket.loki-ruler.arn,
    ]

  }
}

resource "aws_iam_policy" "loki_policy" {
  name        = format("%s-loki", var.project_name)
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.loki_policy.json
}

resource "aws_iam_policy_attachment" "loki" {
  name = "loki"
  roles = [
    aws_iam_role.loki_role.name
  ]

  policy_arn = aws_iam_policy.loki_policy.arn
}

resource "aws_eks_pod_identity_association" "loki" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "loki"
  service_account = "loki"
  role_arn        = aws_iam_role.loki_role.arn
}