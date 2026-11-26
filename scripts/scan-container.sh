#!/usr/bin/env bash
# 4) Build the image, scan it, scan the Kubernetes manifests, write an SBOM
source "$(dirname "$0")/lib.sh"
IMAGE="${IMAGE:-demo-app:local}"
K8S_DIR="${K8S_DIR:-k8s/hardened}"
mkdir -p reports
docker build -t "$IMAGE" app/

trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE" 2>&1 | tee reports/trivy-image.txt
finish "${PIPESTATUS[0]}" "Container image scan (trivy)"

trivy config --severity HIGH,CRITICAL --exit-code 1 "$K8S_DIR" 2>&1 | tee reports/trivy-k8s.txt
finish "${PIPESTATUS[0]}" "Kubernetes manifest scan (trivy config)"

trivy image --format cyclonedx --output reports/sbom.cdx.json "$IMAGE"
echo "SBOM written to reports/sbom.cdx.json"
