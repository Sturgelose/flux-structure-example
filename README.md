# Flux Platform

## Structure

### Cluster

Instantiation of each cluster's 

* flux state, 
* platform namespaces, 
* cluster-level secrets
* tenant applications

Each cluster imports a pre-made profile from the _components folder, 
which provides pre-made configuration for production, SSS or other usages
and avoids making each cluster totally customized.

### Platform

Configurations for each of the subsystems/components that make up the platform.
Some of them are must-have, some others have a choice and some others are optional.

Each component exposes a configuration for each of the cluster profiles that it supports.
Namespaces and secrets won't be initialized here!

### Tenants

Configuration for each of the tenants' namespaces and repos from where to fetch
applications. It delegates the application's CD to the remote repo, but declares
cluster secrets that they might need, RBAC policies and the namespaces where apps will be installed.

DevOps also has a tenant, as Atlantis, GitHub Runners and Grafana UI should
be considered applications that are offered as-a-platform-service.

## Demo

Generate a GitHub personal token and execute the following:

```commandline
$ kind create cluster
$ flux bootstrap github \   
  --owner=sturgelose \
  --repository=flux-platform \
  --path=clusters/sts-devpkg/eu \
  --personal
```

`path` should point to the instance of the cluster, with its secrets and platform kustomization.

You can validate that all flows are up with `flux stats`
And see the whole tree of installed resources and flows with `flux tree kustomization flux-system`

## Design Decisions

### CRDs are installed with the helm charts

They are not removed if we uninstall the chart, so there is no potential data loss implied.
In upgrades, we can stop the reconciliation, update manually and make sure upgrades are fine.

Helm charts including CRDs should only be installed by platform components. Never by applications or we might end in conflicts.

### Secrets and Namespaces are created outside of flows

Otherwise, we are forced to maintain states and files per each cluster and flux flow.
This can be quite inviable and instead this allows us to:

* Make sure none deletes namespaces, provoking data loss
* People cannot move services between namespaces (so we can warn them that they will lose)
* Keep all the cluster secrets together, so we have a single file per cluster, conveniently together. This allows easy update of secrets.
* (WIP) Flux Flows can only install things in the namespace they are declared. Flux-system is the one responsible to install other flows.  
  This means that applications should not require to be aware or decide of where they are installed. It's the platform deciding for them.

### Cluster Operators control which repos can provide Flux configuration

This repo contains references to other flux repos, and the responsible ones to maintain them are the DevOps team.
They do call other repositories depending on the tenants that need to use the cluster, and delegate specific namespaces to specific project/teams.

In the end, this needs to be thruple: namespace, remote_repo and project_name (path in remote_repo).

Thus, we are managing them by using a HelmChart stored in this same repo and that exposes these three parameters.
And because HelmCharts are good at iterating over lists, we will make use of the charts to create all the namespaces and tenants at once.

Each namespace comes with its own service account for flux and sets up the RBAC for the right team.

Kustomizations are not so good at it!

### Try to be DRY

Make use of components or overlays to apply similar configurations and guardrails everywhere:

* Enforce standard tagging in namespaces
* Tolerations and taints for most of the applications
* Potentially, RBAC policies for some namespaces, that should be standard
* Avoid having each cluster individually defined. Let's standardize what we deploy and let's just configure the individual secrets they require.

### Differ