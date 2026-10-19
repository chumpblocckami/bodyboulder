#!/usr/bin/env bash
# Ubuntu 24.04 lacks WebKitGTK 4.0; the SDK manager runs against 4.1 via these symlinks.
DIR="$(cd "$(dirname "$0")" && pwd)"
export LD_LIBRARY_PATH="$DIR/compat-libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$DIR/sdkmanager/bin/sdkmanager" "$@"
