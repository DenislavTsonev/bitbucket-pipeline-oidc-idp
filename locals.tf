locals {
  # clean URL of https:// prefix
  formated_url = replace(var.url, "https://", "")

  pre_formated_repo_uuid = [for repo in var.repository_uuids : replace(repo, "/({)|(})/", "")]

  formated_repo_uuid = [for repo in local.pre_formated_repo_uuid : "{${repo}}:*"]
}
