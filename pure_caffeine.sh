#!/bin/bash

inhibit_pid=""

start_inhibit() {
    if [[ -z "$inhibit_pid" ]]; then
        echo "Starting systemd-inhibit"
        systemd-inhibit --what=idle:sleep --why="Media playing" tail -f /dev/null &
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

# Log or react to PlaybackStatus changes via D-Bus
dbus-monitor "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'" |
while read -r line; do
    if echo "$line" | grep -q "PlaybackStatus"; then
        if echo $(playerctl status -a 2>/dev/null) | grep -q "Playing"; then
            echo "$(date): Playback running"
            start_inhibit
        else
            echo "$(date): Playback stopped"
            stop_inhibit
        fi
    fi
done
