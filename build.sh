#!/usr/bin/env bash
# Usage: ./build.sh [version] [push]
# If 'push' is true, image will be pushed to ECR.
set -eu -o pipefail

VERSION="${1:-1.26.1}" # Version tag for the image, e.g., "1.26.1". Should match the nginx image version in the Dockerfile and the version of the forked code in this repo.
PUSH="${2:-true}"

echo "Using version tag: '$VERSION'"
echo "Whether to push to ECR: '$PUSH'"

ECR_REGISTRY="252622759102.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

IMAGE_TAGS=(
  "$ECR_REGISTRY/nginx:$VERSION"
  "$ECR_REGISTRY/nginx:latest"
)

BUILD_CMD_ARGS=(
  "buildx" "build" "."
  "--file" "./Dockerfile"
  "--pull"
)

for tag in "${IMAGE_TAGS[@]}"; do
  BUILD_CMD_ARGS+=("--tag" "$tag")
done

if [[ "$PUSH" == "true" ]]; then
  BUILD_CMD_ARGS+=("--push")
  echo "Images will be pushed to ECR, reading from and writing to build cache"
else
  BUILD_CMD_ARGS+=("--load")
  echo "Images will be loaded locally (not pushed), reading from build cache"
fi

echo "Starting Docker build..."
echo "Build command: docker ${BUILD_CMD_ARGS[*]}"
docker "${BUILD_CMD_ARGS[@]}"

echo "Docker build completed successfully!"

if [[ "$PUSH" == "push" ]]; then
  echo "Images pushed: ${IMAGE_TAGS[*]}"
else
  echo "Images loaded locally with tags: ${IMAGE_TAGS[*]}"
fi
