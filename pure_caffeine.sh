#!/bin/bash

ALSO_BLOCK_IDLE=0 # uses "--what=sleep:idle" to also prevent the idle state (usually used for turning off monitors)

inhibit_pid=""

start_inhibit() {
    if [[ -z "$inhibit_pid" ]]; then
        echo "Starting systemd-inhibit"
        what_value="sleep"
        if [ "$ALSO_BLOCK_IDLE" -ne 0 ]; then
            what_value="sleep:idle"
        fi
        systemd-inhibit --why="Media is playing. Snorting PURE CAFFEINE." --what="$what_value" sleep infinity &
        inhibit_pid=$!
        echo "$inhibit_pid"
    fi
}

stop_inhibit() {
    if [[ -n "$inhibit_pid" ]]; then
        echo "Stopping systemd-inhibit"
        kill "$inhibit_pid"
        inhibit_pid=""
    fi
}

check_playback() {
    if echo $(playerctl status -a 2>/dev/null) | grep -q "Playing"; then
        echo "$(date): Playback running"
        start_inhibit
    else
        echo "$(date): Playback stopped"
        stop_inhibit
    fi
}

check_playback

# Listen to PlaybackStatus changes via D-Bus
dbus-monitor "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'" |
while read -r line; do
    if echo "$line" | grep -q "PlaybackStatus"; then
        check_playback
    fi
done
