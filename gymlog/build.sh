#!/usr/bin/env bash
# Usage: ./build.sh            build bin/GymLog.prg for the Forerunner 165
#        ./build.sh sim        build, then run it in the simulator
#        ./build.sh install    build, then copy it to the watch plugged in over USB
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
SDKM="$ROOT/bin/connect-iq-sdk-manager"
export PATH="$("$SDKM" sdk current-path --bin):$PATH"
DEVICE=fr165

mkdir -p bin
monkeyc -f monkey.jungle -d "$DEVICE" -y "$ROOT/keys/developer_key.der" -o bin/GymLog.prg -w

case "${1:-}" in
    sim)
        monkeydo bin/GymLog.prg "$DEVICE"
        ;;
    install)
        # Garmin watches show up over MTP, which GNOME mounts under gvfs.
        APPS="$(ls -d /run/user/"$(id -u)"/gvfs/mtp:host=091e_*/*/GARMIN/Apps 2>/dev/null | head -1 || true)"
        [ -n "$APPS" ] || { echo "Watch not found: plug it in, wake it, and open it once in Files." >&2; exit 1; }
        gio remove "$APPS/GymLog.prg" 2>/dev/null || true
        gio copy bin/GymLog.prg "$APPS/"
        echo "Installed. Unplug the watch; BodyBoulder appears in the activity list."
        ;;
esac
