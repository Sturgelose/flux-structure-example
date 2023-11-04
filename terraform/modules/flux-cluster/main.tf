resource "github_repository_deploy_key" "this" {
  title      = "flux-cd/${var.cluster_name}"
  repository = var.github_repository
  key        = var.public_key_openssh
  read_only  = "false"
}


# Bootstrap flux
resource "flux_bootstrap_git" "this" {
  path = "clusters/${var.cluster_name}"

  # Let's depend on the secrets and configs so at first boot flux them in-place
  # Otherwise, it takes 10min to reconcile
  depends_on = [
    github_repository_deploy_key.this,
    github_repository_file.config,
    github_repository_file.kustomization,
    github_repository_file.secrets,
  ]
}

# Custom profile management
locals {
  flux_platform_path = "clusters/${var.cluster_name}/platform"
}

resource "github_repository_file" "kustomization" {
  repository          = var.github_repository
  branch              = "main"
  commit_message      = "[Flux] Configure Kustomization for ${var.cluster_name}"
  overwrite_on_create = false
  file                = "${local.flux_platform_path}/kustomization.yaml"
  content             = templatefile(
    "${path.module}/templates/kustomization.sample.yaml", 
    {
      profile_name = var.profile_name
    }
  )
}


resource "github_repository_file" "secrets" {
  repository          = var.github_repository
  branch              = "main"
  commit_message      = "[Flux] Configure cluster secrets for ${var.cluster_name}"
  overwrite_on_create = false
  file                = "${local.flux_platform_path}/cluster-secrets.yaml"
  content             = templatefile(
      "${path.module}/templates/secrets.sample.yaml", 
      {
        # TODO Secrets should be stored encrypted with a provided SOPS key before committing
        data = [for key, val in var.cluster_secrets : "${key}: encrypted(${val})"]
      }
    )
}

resource "github_repository_file" "config" {
  repository          = var.github_repository
  branch              = "main"
  commit_message      = "[Flux] Configure cluster config for ${var.cluster_name}"
  overwrite_on_create = false
  file                = "${local.flux_platform_path}/cluster-config.yaml"
  content             = templatefile(
    "${path.module}/templates/config.sample.yaml", 
    {
      data = [ for key, val in var.cluster_config : "${key}: ${val}"]
    }
  )
}