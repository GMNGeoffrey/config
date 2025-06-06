#!/bin/bash

# Repeatedly try to start a gcp instance and ssh into it. Mostly useful for GPU
# instances where stockouts are common.

set -euo pipefail

instance_name="$1"
zone="${2:-}"

function get_zone() {
    # macos doesn't have readarray :-(
    local -a zones=( $(gcloud compute instances list --filter="name=$1" --format="value(zone)") )
    if (( "${#zones[@]}" == 0 )); then
        echo "No instances with name '$1' found." >&2
        (set -x; gcloud compute instances list --filter="name=$1") >&2
        exit 1
    fi
    if (( "${#zones[@]}" != 1 )); then
        echo "Multiple instances with name '$1' found, please specify a zone." >&2
        (set -x; gcloud compute instances list --filter="name=$1") >&2
        exit 1
    fi
    echo "${zones[0]}"
}

function get_status() {
    gcloud compute instances describe "$1" --zone="$2" --format="value(status)"
}

function start_instance() {
    gcloud compute instances start "$1" --zone="$2"
}

function check_ssh_available() {
    (set +o pipefail; \
        ssh -o BatchMode=yes -o ConnectTimeout=5 -o PubkeyAuthentication=no -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o ChallengeResponseAuthentication=no "$1" 2>&1 \
        | fgrep -q "Permission denied" \
    )
}

if [[ -z "${zone}" ]]; then
    zone="$(get_zone "${instance_name}")"
fi

while [[ $(get_status "${instance_name}" "${zone}") != "RUNNING" ]]; do
    start_instance "${instance_name}" "${zone}" && true
    sleep 30
done

echo -n "Waiting for ssh to become available"
while ! check_ssh_available "gcp.${instance_name}"; do
    echo -n "."
    sleep 5
done

echo "done"

if [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
    it2attention start
    it2attention fireworks
fi

exec ssh "gcp.${instance_name}"
