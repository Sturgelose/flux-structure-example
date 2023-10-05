provider "flux" {
  kubernetes = {
   config_path = "~/.kube/config"
   config_context = local.k8s_config_name
  }
  git = {
    url = "ssh://git@github.com/${local.github_org}/${local.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

# Bootstrap flux
resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  path = "clusters/housy"
}