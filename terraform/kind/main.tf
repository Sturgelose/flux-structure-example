locals {
    ## PROVIDER CONFIG
    # GitHub App credentials
    github_app_id = "403427"
    github_app_installation_id = "42574484"
    pem_file = file("${path.module}/private-key.pem")

    # Flux repo configuration
    github_org = "Sturgelose"
    github_repository = "flux-structure-example"

    ## CLUSTER CONFIG
    cluster_name = "kind-home"
}

resource "kind_cluster" "this" {
  name = local.cluster_name
}

# Deploy Key Generation (used by the Flux provider)
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

module "flux" {
  source = "../modules/flux-cluster"

  cluster_name = kind_cluster.this.name
  public_key_openssh = tls_private_key.flux.public_key_openssh

  profile_name = "home"
  cluster_secrets = {
    foo = "bar"
  }
  cluster_config = {
    foo2 = "bar2"
  }
}
