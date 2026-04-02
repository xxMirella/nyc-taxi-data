data "aws_iam_policy_document" "databricks_trust" {
  statement {
    sid     = "AllowDatabricksAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.databricks_principal_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_external_id]
    }
  }

  statement {
    sid     = "AllowSelfAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:role/${var.role_name}"]
    }
  }
}

resource "aws_iam_role" "databricks_s3_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.databricks_trust.json
}

resource "aws_iam_role_policy_attachment" "databricks_attach_policy" {
  role       = aws_iam_role.databricks_s3_role.name
  policy_arn = aws_iam_policy.databricks_s3_policy.arn
}