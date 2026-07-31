#!/bin/bash

ALSO_BLOCK_IDLE=0 # uses "--what=sleep:idle" to also prevent the idle state (usually used for turning off monitors)

for dep in playerctl dbus-monitor systemd-inhibit; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Missing dependency: $dep" >&2
        exit 1
    fi
done

inhibit_pid=""

start_inhibit() {
    if [[ -z "$inhibit_pid" ]] || ! kill -0 "$inhibit_pid" 2>/dev/null; then
        echo "Starting systemd-inhibit..."
        what_value="sleep"
        if [ "$ALSO_BLOCK_IDLE" -ne 0 ]; then
            what_value="sleep:idle"
        fi
        systemd-inhibit --why="Media is playing. Snorting PURE CAFFEINE." --what="$what_value" sleep infinity &
        inhibit_pid=$!
        echo "Started systemd-inhibit process with PID: $inhibit_pid"
    fi
}

stop_inhibit() {
    if [[ -n "$inhibit_pid" ]]; then
        if kill -0 "$inhibit_pid" 2>/dev/null; then
            echo "Stopping systemd-inhibit..."
            # systemd-inhibit forks "sleep infinity" as a child and just waits on
            # it; killing systemd-inhibit itself orphans that child forever, so
            # kill the child first and let systemd-inhibit notice and exit.
            pkill -TERM -P "$inhibit_pid" 2>/dev/null
            kill "$inhibit_pid" 2>/dev/null
            wait "$inhibit_pid" 2>/dev/null
            echo "Stopped systemd-inhibit process with PID: $inhibit_pid"
        fi
        inhibit_pid=""
    fi
}

cleanup() {
    stop_inhibit
    # also reap the dbus-monitor/while-loop pipeline below, which are direct
    # children of this script
    pkill -TERM -P $$ 2>/dev/null
}
trap cleanup EXIT
trap exit INT TERM

check_playback() {
    if playerctl status -a 2>/dev/null | grep -q "Playing"; then
        echo "playerctl status: Playback running"
        start_inhibit
    else
        echo "playerctl status: Playback stopped"
        stop_inhibit
    fi
}

check_playback

# Listen to PlaybackStatus changes via D-Bus.
# Run in the background and `wait` on it (rather than as a foreground
# pipeline) because bash defers running signal traps until a foreground
# command completes, and this pipeline never completes on its own.
dbus-monitor "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'" |
while read -r line; do
    if echo "$line" | grep -q "PlaybackStatus"; then
        check_playback
    fi
done &
monitor_pid=$!
wait "$monitor_pid"
