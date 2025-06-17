#!/usr/bin/env bash
set -euo pipefail

# Installs dependencies for Uno Platform development (GTK frontends)
# Should be run as root inside Ubuntu-based containers or CI environments

if [[ "$(id -u)" -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
WEBKIT_DEV_PKG=libwebkit2gtk-4.0-dev
if ! apt-cache show "$WEBKIT_DEV_PKG" >/dev/null 2>&1; then
  WEBKIT_DEV_PKG=libwebkit2gtk-4.1-dev
  if ! apt-cache show "$WEBKIT_DEV_PKG" >/dev/null 2>&1; then
    echo "No suitable libwebkit2gtk development package found" >&2
    exit 1
  fi
fi

apt-get install -y --no-install-recommends \
  libgtk-3-dev \
  "$WEBKIT_DEV_PKG" \
  curl wget git gnupg ca-certificates software-properties-common apt-transport-https

# Add Microsoft package repository and install .NET 8 SDK + ASP.NET runtime
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get update
apt-get install -y --no-install-recommends dotnet-sdk-8.0 aspnetcore-runtime-8.0

apt-get clean
rm -rf /var/lib/apt/lists/*

