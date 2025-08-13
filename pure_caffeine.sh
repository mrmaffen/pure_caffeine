#!/bin/bash

inhibit_pid=""

start_inhibit() {
    if [[ -z "$inhibit_pid" ]]; then
        echo "Starting systemd-inhibit"
        # PURE_CAFFEINE=1 just to mark the process
        systemd-inhibit --what=idle:sleep --why="Media is playing. Snorting pure caffeine." env PURE_CAFFEINE=1 sleep infinity &
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
