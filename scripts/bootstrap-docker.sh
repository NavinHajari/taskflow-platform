#!/usr/bin/env bash
# Installs Docker Engine via Homebrew + Colima on macOS (Apple Silicon or Intel).
# macOS equivalent of bootstrap-docker.sh (Ubuntu 24.04).
# Idempotent: safe to re-run.
set -euo pipefail

echo "==> Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon installs to /opt/homebrew, Intel to /usr/local
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

echo "==> Updating base packages"
brew update
brew install git make jq

echo "==> Installing Docker CLI and Colima runtime"
brew install docker docker-compose docker-buildx colima

echo "==> Wiring compose and buildx as docker CLI plugins"
mkdir -p ~/.docker/cli-plugins
ln -sfn "$(brew --prefix)/opt/docker-compose/bin/docker-compose" \
  ~/.docker/cli-plugins/docker-compose
ln -sfn "$(brew --prefix)/opt/docker-buildx/bin/docker-buildx" \
  ~/.docker/cli-plugins/docker-buildx

echo "==> Starting Colima VM"
colima status >/dev/null 2>&1 || colima start --cpu 2 --memory 4 --disk 20

echo "==> Done. No docker group needed on macOS."
docker --version
docker compose version
docker run --rm hello-world
