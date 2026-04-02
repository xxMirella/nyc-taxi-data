locals {
  github_sub = var.github_environment != ""
    ? "repo:${var.github_repo}:environment:${var.github_environment}"
    : "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "AllowGitHubActionsOIDC"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_sub]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy_role" {
  name               = var.deploy_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = var.deploy_role_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy_role_policy" {
  role       = aws_iam_role.github_actions_deploy_role.name
  policy_arn = var.deploy_role_policy_arn
}