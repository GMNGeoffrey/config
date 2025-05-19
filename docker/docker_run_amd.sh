#!/bin/bash

set -euo pipefail

function docker_run() {
    local -a ARGS=(
        # interactive and launch a terminal
        -it
        # delete the container when it stops. If you change your mind you can
        # commit a running container to an image with docker commit
        # <container_id or container_name> <new_image_name>. If I get around to
        # turning this into a proper python script, would be nice to add a
        # `--keep` flag instead to change the default.
        --rm
        # Name the container with username so we can identify who owns it later.
        # Unfortunately, we don't have a good way of taking additional user
        # input here and appending the username. This can be overridden entirely
        # by just passing the `--name` flag again though.
        --name "${USER}_$(date "+%Y-%m-%d_%H_%M_%S")"
        # Pass through the timezone
        --env TZ="${TZ:-$(cat /etc/timezone)}"
    )

    # Give the container all the permissions including for AMD GPUs.
    # https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html
    ARGS+=(
        --network=host
        --device=/dev/kfd
        --device=/dev/dri
        --ipc=host
        --shm-size 16G
        --group-add video
        --cap-add=SYS_PTRACE
        --security-opt seccomp=unconfined

        # Pass through the visible GPU devices so the container respects that.
        --env CUDA_VISIBLE_DEVICES
        --env HIP_VISIBLE_DEVICES
    )

    set -x
    exec docker run "${ARGS[@]}" "$@"
}

docker_run "$@"

