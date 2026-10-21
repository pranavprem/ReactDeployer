#!/bin/bash
# Cloud-init script processed by Terraform templatefile.
# Bash variables in this file are escaped as $${name} so Terraform leaves them alone.
set -euo pipefail
exec > >(tee -a /var/log/react-deploy-bootstrap.log) 2>&1

export DEBIAN_FRONTEND=noninteractive
export GIT_TERMINAL_PROMPT=0

GITHUB_OWNER="${github_owner}"
REPO_NAME="${repo_name}"
SERVER_PORT="${server_port}"
NODE_VERSION="${node_version}"

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl git xz-utils

arch="$(dpkg --print-architecture)"
case "$${arch}" in
  amd64) node_arch="x64" ;;
  arm64) node_arch="arm64" ;;
  *)
    echo "Unsupported architecture: $${arch}" >&2
    exit 1
    ;;
esac

tarball="node-v$${NODE_VERSION}-linux-$${node_arch}.tar.xz"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$${tmpdir}"' EXIT

curl -fsSL --retry 5 --retry-delay 2 "https://nodejs.org/dist/v$${NODE_VERSION}/SHASUMS256.txt" -o "$${tmpdir}/SHASUMS256.txt"
curl -fsSL --retry 5 --retry-delay 2 "https://nodejs.org/dist/v$${NODE_VERSION}/$${tarball}" -o "$${tmpdir}/$${tarball}"
(
  cd "$${tmpdir}"
  grep -F "  $${tarball}" SHASUMS256.txt | sha256sum -c -
)
tar -xJf "$${tmpdir}/$${tarball}" -C /usr/local --strip-components=1

if ! id react >/dev/null 2>&1; then
  useradd --system --create-home --home-dir /opt/react --shell /usr/sbin/nologin react
fi
install -d -o react -g react /opt/react/app

runuser -u react -- env HOME=/opt/react GIT_TERMINAL_PROMPT=0 \
  git clone --depth 1 "https://github.com/$${GITHUB_OWNER}/$${REPO_NAME}.git" /opt/react/app
runuser -u react -- env HOME=/opt/react \
  bash -c 'cd /opt/react/app && npm install'

cat >/etc/systemd/system/react-dev.service <<'UNIT'
[Unit]
Description=React dev server (${repo_name})
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=react
Group=react
WorkingDirectory=/opt/react/app
Environment=HOME=/opt/react
Environment=HOST=0.0.0.0
Environment=PORT=${server_port}
ExecStart=/usr/local/bin/npm run dev
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now react-dev.service
systemctl --no-pager --full status react-dev.service
echo "Bootstrap finished for $${GITHUB_OWNER}/$${REPO_NAME} on port $${SERVER_PORT}."
