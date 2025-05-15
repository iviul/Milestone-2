#!/bin/bash
set -euo pipefail

# Variables
# Check for required arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 <config_path> <image_name>"
  exit 1
fi

# Variables
CONFIG_PATH=$1
IMAGE_NAME=$2
TAG="latest"

echo "Got file: $CONFIG_PATH"

# Use grep with extended regex (-E) and sed to extract region and repo_name
REGION=$(grep -E '"repository_location_gcp":' "$CONFIG_PATH" | sed -E 's/.*"repository_location_gcp": *"([^"]+)".*/\1/')
echo "Got region: $REGION"

REPO_NAME=$(grep -E '"repo_name":' "$CONFIG_PATH" | sed -E 's/.*"repo_name": *"([^"]+)".*/\1/')
echo "Got repo name: $REPO_NAME"

# Ensure gcloud is installed and configured
if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud command not found. Please install Google Cloud SDK first."
  exit 1
fi

PROJECT_ID=$(gcloud config get-value project)
echo "Project ID: $PROJECT_ID"
echo "=== Configuring Docker to use gcloud as a credential helper ==="
gcloud auth configure-docker "$REGION-docker.pkg.dev"

echo "=== Building Docker image ==="
docker build -t  "$IMAGE_NAME:$TAG" .

echo "=== Tagging Docker image ==="
DOCKER_IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$TAG"
docker tag "$IMAGE_NAME:$TAG" "$DOCKER_IMAGE_URI"

echo "=== Pushing Docker image to Artifact Registry ==="
docker push "$DOCKER_IMAGE_URI"

echo "=== Docker image management completed ===" 