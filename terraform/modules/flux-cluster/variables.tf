variable "cluster_name" {
  type = string
}

variable "github_repository" {
    description = "Name of the repository where the flux bootstrap will happen"
    default = "flux-platform"
    type = string 
}

variable "public_key_openssh" {
    description = "Public OpenSSH key to use to sync K8s cluster with flux bootstrap repository"
    type = string
}

variable "profile_name" {
  description = "Profile name to use from flux bootstrap repository"
  type = string
}

variable "cluster_secrets" {
  description = "Cluster secrets to be installed in flux-system namespace"
  type = map
  default = {}
  sensitive = true
}

variable "cluster_config" {
  description = "Cluster config to be installed in the fux-system namespace"
  type = map
  default = {}
}

