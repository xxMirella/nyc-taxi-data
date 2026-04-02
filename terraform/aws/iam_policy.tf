data "aws_iam_policy_document" "databricks_s3_access" {
  statement {
    sid    = "ListBronzePrefix"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        var.bronze_prefix,
        "${var.bronze_prefix}/*"
      ]
    }
  }

  statement {
    sid    = "ReadWriteBronzeObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/${var.bronze_prefix}/*"
    ]
  }
}

resource "aws_iam_policy" "databricks_s3_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.databricks_s3_access.json
}