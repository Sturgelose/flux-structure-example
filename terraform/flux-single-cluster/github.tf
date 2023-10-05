provider "github" {}

# Deploy Key Generation (used by the Flux provider)

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "flux-cd/${local.cluster_name}"
  repository = local.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}