#!/usr/bin/env bash
# The SDK simulator needs WebKitGTK 4.0 + libsoup2, which Ubuntu 24.04 no longer ships,
# so it runs in an Ubuntu 22.04 container drawing on the host X display.
set -euo pipefail
SDK_BIN="$("$(dirname "$0")/../bin/connect-iq-sdk-manager" sdk current-path --bin)"
xhost +SI:localuser:"$(id -un)" >/dev/null
exec docker run --rm --name ciq-sim \
    --network host \
    --user "$(id -u):$(id -g)" \
    -e DISPLAY="$DISPLAY" -e HOME="$HOME" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$HOME/.Garmin:$HOME/.Garmin" \
    -v "$SDK_BIN:$SDK_BIN:ro" \
    ciq-sim:22.04 "$SDK_BIN/simulator"
