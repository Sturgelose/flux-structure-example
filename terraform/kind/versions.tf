terraform {
  required_version = "~>1.6.0"

  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "~>1.1.2"
    }
    github = {
      source  = "integrations/github"
      version = "~>5.41"
    }
    kind = {
      source = "tehcyx/kind"
      version = "~>0.2.1"
    }
  }
}

provider "github" {
  owner = local.github_org
  app_auth {
    id = local.github_app_id
    installation_id = local.github_app_installation_id
    pem_file = local.pem_file
  }
}

provider "kind" {}

provider "flux" {
  # kubernetes = {
  #  config_path = "~/.kube/config"
  #  config_context = local.k8s_config_name
  # }

  kubernetes = {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
  }
  git = {
    url = "ssh://git@github.com/${local.github_org}/${local.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}