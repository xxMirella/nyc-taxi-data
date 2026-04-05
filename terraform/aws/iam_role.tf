locals {
  has_valid_databricks_principal = trimspace(var.databricks_principal_arn) != "" && var.databricks_principal_arn != "arn:aws:iam::000000000000:root"
  has_valid_databricks_external  = trimspace(var.databricks_external_id) != "" && var.databricks_external_id != "TEMP_EXTERNAL_ID"
  create_databricks_role         = local.has_valid_databricks_principal && local.has_valid_databricks_external
}

data "aws_iam_policy_document" "databricks_trust" {
  count = local.create_databricks_role ? 1 : 0

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
}

resource "aws_iam_role" "databricks_s3_role" {
  count = local.create_databricks_role ? 1 : 0

  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.databricks_trust[0].json
}

resource "aws_iam_role_policy_attachment" "databricks_attach_policy" {
  count = local.create_databricks_role ? 1 : 0

  role       = aws_iam_role.databricks_s3_role[0].name
  policy_arn = aws_iam_policy.databricks_s3_policy.arn
}
