#!/bin/sh
UBUNTU_VERSION='22.04'
KEY_URL="https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/unstable/xUbuntu_${UBUNTU_VERSION}/Release.key"
SOURCES_URL="https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/unstable/xUbuntu_${UBUNTU_VERSION}"
echo "deb $SOURCES_URL/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list
curl -fsSL $KEY_URL | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/devel_kubic_libcontainers_unstable.gpg > /dev/null
