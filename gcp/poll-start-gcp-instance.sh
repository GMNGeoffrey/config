#!/bin/bash

# Repeatedly try to start a gcp instance and ssh into it. Mostly useful for GPU
# instances where stockouts are common.

set -euo pipefail

instance_name="$1"

function get_status() {
    gcloud compute instances describe "$1" --format="value(status)"
}

function start_instance() {
    gcloud compute instances start "$1"
}

function check_ssh_available() {
    (set +o pipefail; \
        ssh -o BatchMode=yes -o ConnectTimeout=5 -o PubkeyAuthentication=no -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o ChallengeResponseAuthentication=no "$1" 2>&1 \
        | fgrep -q "Permission denied" \
    )
}

while [[ $(get_status "${instance_name}") != "RUNNING" ]]; do
    start_instance "${instance_name}" && true
    sleep 30
done

while ! check_ssh_available "gcp.${instance_name}"; do
    sleep 5
done

if [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
    it2attention start
    it2attention fireworks
fi

exec ssh "gcp.${instance_name}"
