# Platform

Subsystems (applications) that conform the platform in the K8s cluster.
Some of them are required in any cluster and some others are optional per cluster.

Each subsystem may require cloud resources or external configurations to run,
they need to be created and injected into the cluster before installing the platform.

## Structure

Each subsystem app exposes multiple profiles, so each cluster profile has a predefined configuration for each subsystem.
Subsystem applications always run with `cluster-critical` priority and in namespace where the default toleration is to run in the system nodes.

Each subsystem app should has as less configuration as possible. Most of the configuration should be common for all the profiles, which is stored in the `_base` folder. Then, if it is needed, patches can be used to override specific configurations per subsystem profile.

The namespace is included in the subsystem app and is created whenever the app is deployed.

The application should be instantiated by a FluxCD Kustomization. And, if the application requires per-cluster configuration, templating and substitution (supported by FluxCD Kustomization) can be used to setup the secrets and configmaps.

Also, each subsystem app should aim to be either a simple HelmRelease or have a minimal amount of resources.

HelmReleases should install CRDs but disable upgrade or deletion of CRDs. Upgrade will always be done manually by cluster operators.
