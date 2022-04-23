module "bitbucket_idp" {
  source = "../"

  name             = "bitbucket-idp"
  url              = "https://api.bitbucket.org/2.0/workspaces/<your_workspace>/pipelines-config/identity/oidc"
  client_id_list   = ["ari:cloud:bitbucket::workspace/8a1fdadad-cbc0-452c-81ce-07534945e18b"]
  thumbprint_list  = ["a031c467fffaaa87c76da9aa62ccabd8e"]
  repository_uuids = ["{437da666-7aab-4b60-a947-ec542536ca0d}", "03baea80-974f-432a-8d42-183fad107439"]
}


openssl s_client -servername api.bitbucket.org -showcerts -connect api.bitbucket.org:443