resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = var.client_id_list
  thumbprint_list = var.thumbprint_list
  url             = var.url
}

data "aws_iam_policy_document" "assume_role_with_oidc" {
  for_each = var.role_per_repository ? toset(local.formated_repo_uuid) : toset(["onerole"])

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.formated_url}"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.formated_url}:sub"
      values   = var.role_per_repository ? toset(each.key) : toset(local.formated_repo_uuid)
    }

    dynamic "condition" {
      for_each = length(var.bitbucket_public_ips) > 0 ? ["enable"] : []

      content {
        test     = "IpAddress"
        variable = "aws:SourceIp"
        values   = var.bitbucket_public_ips
      }
    }
  }
}

resource "aws_iam_role" "this" {
  for_each           = var.role_per_repository ? toset(local.formated_repo_uuid) : toset(["onerole"])
  name               = var.name != "" ? "${var.name}-role-${each.key}" : null
  name_prefix        = var.name == "" ? "bitbucket-oidc-${each.key}" : null
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_oidc[each.key].json
}

resource "aws_iam_role_policy_attachment" "default" {
  for_each = var.role_per_repository ? toset(local.formated_repo_uuid) : toset(["onerole"])

  role       = aws_iam_role.this[each.key].name
  policy_arn = var.role_per_repository && length(var.policy_arn_per_repo) > 0 ? var.policy_arn_per_repo[each.key] : aws_iam_policy.default[each.key].arn

}

resource "aws_iam_policy" "default" {
  for_each    = var.role_per_repository ? toset([]) : toset(["onerole"])
  name        = var.name != "" ? "${var.name}-policy" : null
  name_prefix = var.name == "" ? "oidc-policy-default-all-repos" : null
  description = "Policy which will be assumed by all Bitbucket repos via IdP"
  policy      = templatefile("${path.module}/policies/default.json", {})
}
