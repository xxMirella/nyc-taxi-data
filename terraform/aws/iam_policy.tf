# --- Documento de Política para S3 (Bronze Layer) ---
data "aws_iam_policy_document" "databricks_s3_access" {
  statement {
    sid       = "ListBronzePrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]

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
    resources = ["arn:aws:s3:::${var.bucket_name}/${var.bronze_prefix}/*"]
  }
}

data "aws_iam_policy_document" "databricks_logging_access" {
  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "databricks_s3_policy" {
  name        = var.policy_name
  description = "Acesso granular do Databricks à camada Bronze no S3"
  policy      = data.aws_iam_policy_document.databricks_s3_access.json
}

resource "aws_iam_policy" "databricks_logging_policy" {
  name        = "databricks-cloudwatch-logging-policy"
  description = "Permite que o Job Databricks envie logs para o CloudWatch"
  policy      = data.aws_iam_policy_document.databricks_logging_access.json
}