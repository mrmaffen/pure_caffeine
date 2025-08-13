# PURE CAFFEINE
### ~ *inhibit system sleep when media is playing* ~

Simple bash script that stops your system from suspending/hibernating whenever media is playing.
Works by monitoring dbus for "PlaybackStatus"-changed events and then checking whether or not media is playing through playerctl. If it is, systemd-inhibit is used with a "fake" process to inhibit sleep/hibernation.
No polling required. All event-based.

### Dependencies
- systemd-inhibit (systemd)
- dbus-monitor (dbus)
- playerctl

### Install as a systemd service
- Copy pure_caffeine.service into ~/.config/systemd/user
- Edit pure_caffeine.service, adjust ExecStart to point to pure_caffeine.sh
- Run "systemctl --user daemon-reload"
- Run "systemctl --user enable --now pure_caffeine.service"
- Verify service is running with "systemctl --user status pure_caffeine.service"
- Verify functionality with "systemd-inhibit". Whenever media is playing, it should list an inhibitor with WHY="Media is Playing"

### License
Copyright (C) 2025 github.com/mrmaffen

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. See [LICENSE](LICENSE)

If not, see <http://www.gnu.org/licenses/>.

#### *Not legally binding TL;DR:*
- *Anyone can copy, modify, and distribute this software.*
- *You must include the license and copyright notice with any distribution.*
- *Private use is unrestricted.*
- *Commercial use is allowed.*
- *If you distribute modified versions, you must release them under GPLv3.*
- *You must indicate any changes you make to the original code.*
- *Modifications that are distributed must carry the same GPLv3 license.*
- *The software comes with no warranty.*
- *The author is not liable for any damage resulting from the software.*
