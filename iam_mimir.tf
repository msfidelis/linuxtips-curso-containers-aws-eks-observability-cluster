data "aws_iam_policy_document" "mimir_role" {
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

resource "aws_iam_role" "mimir_role" {
  assume_role_policy = data.aws_iam_policy_document.mimir_role.json
  name               = format("%s-mimir", var.project_name)
}

data "aws_iam_policy_document" "mimir_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "s3:*",
    ]

    resources = [
      format("%s/*", aws_s3_bucket.mimir.arn),
      format("%s/*", aws_s3_bucket.mimir_ruler.arn),
      aws_s3_bucket.mimir.arn,
      aws_s3_bucket.mimir_ruler.arn,
    ]

  }
}

resource "aws_iam_policy" "mimir_policy" {
  name        = format("%s-mimir", var.project_name)
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.mimir_policy.json
}

resource "aws_iam_policy_attachment" "mimir" {
  name = "mimir"
  roles = [
    aws_iam_role.mimir_role.name
  ]

  policy_arn = aws_iam_policy.mimir_policy.arn

}

resource "aws_eks_pod_identity_association" "mimir" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "mimir"
  service_account = "mimir"
  role_arn        = aws_iam_role.mimir_role.arn
}

resource "aws_eks_pod_identity_association" "mimir_ruler" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "mimir"
  service_account = "mimir-ruler"
  role_arn        = aws_iam_role.mimir_role.arn
}