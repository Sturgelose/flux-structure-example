#!/usr/bin/env bash

# mirror kustomize-controller build options of fluxCD
kustomize_flags=("--load-restrictor=LoadRestrictionsNone")

# Skip Kubernetes Secrets due to SOPS fields failing validation
# Download CRDs
# Ignore patches
mkdir -p /tmp/kconform-cache
kubeconform_config=("-summary" "-skip=Secret" "-ignore-filename-pattern=-patch.yaml" "-strict" "-ignore-missing-schemas" "-cache=/tmp/kconform-cache" "-schema-location" "default" "-schema-location" "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json")

# Validate with Kubeconform
# for dir in "clusters" "platform" "tenants";
# do
#     echo "Searching in ./$dir"
#     kubeconform "${kubeconform_config[@]}" $dir
# done

# Validate built Kustomizations with Kubeconform
for kfile in $(find -regex "./\(platform\|clusters\)/.*/kustomization.yaml" -type f)
do
    echo "Building Kustomization $(dirname $kfile)"
    kustomize build "${kustomize_flags[@]}" $(dirname $kfile) | \
        kubeconform "${kubeconform_config[@]}"
done