#!/usr/bin/env bash
set -o errexit

podman run --rm --name test-container -it localhost/screen screen -v
