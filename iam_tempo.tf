data "aws_iam_policy_document" "tempo_role" {
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

resource "aws_iam_role" "tempo_role" {
  assume_role_policy = data.aws_iam_policy_document.tempo_role.json
  name               = format("%s-tempo", var.project_name)
}

data "aws_iam_policy_document" "tempo_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "s3:*",
    ]

    resources = [
      format("%s/*", aws_s3_bucket.tempo.arn),
      aws_s3_bucket.tempo.arn,
    ]

  }
}

resource "aws_iam_policy" "tempo_policy" {
  name        = format("%s-tempo", var.project_name)
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.tempo_policy.json
}

resource "aws_iam_policy_attachment" "tempo" {
  name = "tempo"
  roles = [
    aws_iam_role.tempo_role.name
  ]

  policy_arn = aws_iam_policy.tempo_policy.arn
}

resource "aws_eks_pod_identity_association" "tempo" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "tempo"
  service_account = "tempo"
  role_arn        = aws_iam_role.tempo_role.arn
}