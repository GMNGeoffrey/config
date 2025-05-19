#!/bin/bash

HOST="$1"
PORT="$2"

HOST="${HOST##gcp.}"

get_zone() {
    local name=$1
    gcloud compute instances list --filter="name=('${name}')" --format "value(zone)"
}

get_host() {
    local name=$1
    local zone="$(get_zone "${name}")"
    gcloud compute instances describe --zone="${zone}" "${name}" --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
}

nc "$(get_host "$HOST")" "$PORT"
