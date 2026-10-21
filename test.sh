#!/usr/bin/env bash
# Request the load balancer until the dev server answers or the boot window ends.
# Apply does not wait for npm install; see health_check_grace_period.
set -euo pipefail

if ! url="$(terraform output -raw alb_url)"; then
  echo "terraform output failed. Initialize the application stack before running test.sh." >&2
  exit 1
fi

echo "Requesting ${url}"

attempts=45
for attempt in $(seq 1 "${attempts}"); do
  if curl --fail --silent --show-error --max-time 10 "${url}"; then
    echo
    exit 0
  fi
  echo "Not ready yet (attempt ${attempt}/${attempts}). Retrying in 20s."
  sleep 20
done

echo "The load balancer did not return a successful response." >&2
echo "On an instance: journalctl -u react-dev and /var/log/react-deploy-bootstrap.log" >&2
exit 1
