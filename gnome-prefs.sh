#!/bin/bash
set -e

wget -O- https://github.com/aXe1/gnome-shell-extension-maximized-by-default/archive/v1.1.0.tar.gz | tar xz -C /tmp
(cd /tmp/gnome-shell-extension-maximized-by-default-1.1.0 && \
	./build.sh && \
	gnome-extensions install dist/gnome-shell-extension-maximized-by-default.zip)

echo 'Installing extensions...'
sudo apt update
sudo apt install \
	gnome-shell-extension-hide-activities \
	gnome-shell-extension-impatience \
	gnome-shell-extension-move-clock \
	gnome-shell-extension-multi-monitors \
	gnome-shell-extension-system-monitor

gnome-extensions enable 'launch-new-instance@gnome-shell-extensions.gcampax.github.com'
gnome-extensions enable 'windowsNavigator@gnome-shell-extensions.gcampax.github.com'
gnome-extensions enable 'Hide_Activities@shay.shayel.org'
gnome-extensions enable 'impatience@gfxmonk.net'
gnome-extensions enable 'workspace-indicator@gnome-shell-extensions.gcampax.github.com'
gnome-extensions enable 'system-monitor@paradoxxx.zero.gmail.com'
gnome-extensions enable 'gnome-shell-extension-maximized-by-default@axe1.github.com'

cat <<EOF | dconf load /
[org/gnome/desktop/input-sources]
xkb-options=['ctrl:swapcaps']

[org/gnome/desktop/interface]
clock-show-date=true
clock-show-weekday=true
enable-hot-corners=false
monospace-font-name='DejaVu Sans Mono 11'

[org/gnome/desktop/privacy]
remember-recent-files=false

[org/gnome/desktop/wm/keybindings]
close=['<Shift><Super>q']
cycle-windows=['<Super>Right']
cycle-windows-backward=['<Super>Left']
move-to-workspace-1=['<Shift><Super>1']
move-to-workspace-2=['<Shift><Super>2']
move-to-workspace-3=['<Shift><Super>3']
move-to-workspace-4=['<Shift><Super>4']
move-to-workspace-5=['<Shift><Super>5']
move-to-workspace-6=['<Shift><Super>6']
move-to-workspace-7=['<Shift><Super>7']
move-to-workspace-8=['<Shift><Super>8']
move-to-workspace-9=['<Shift><Super>9']
switch-applications=['<Super>Tab']
switch-applications-backward=['<Shift><Super>Tab']
switch-to-workspace-1=['<Super>1']
switch-to-workspace-2=['<Super>2']
switch-to-workspace-3=['<Super>3']
switch-to-workspace-4=['<Super>4']
switch-to-workspace-5=['<Super>5']
switch-to-workspace-6=['<Super>6']
switch-to-workspace-7=['<Super>7']
switch-to-workspace-8=['<Super>8']
switch-to-workspace-9=['<Super>9']
switch-windows=['<Alt>Tab']
switch-windows-backward=['<Shift><Alt>Tab']

[org/gnome/desktop/wm/preferences]
focus-mode='sloppy'
num-workspaces=9

[org/gnome/mutter]
dynamic-workspaces=false
workspaces-only-on-primary=true

[org/gnome/mutter/keybindings]
toggle-tiled-left=['']
toggle-tiled-right=['']

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
binding='<Super>Return'
command='gnome-terminal --window --maximize'
name='Launch terminal'

[org/gnome/settings-daemon/plugins/xsettings]
antialiasing='grayscale'
hinting='full'

[org/gnome/shell/extensions/net/gfxmonk/impatience]
speed-factor=0.5

[org/gnome/shell/extensions/system-monitor]
battery-display=false
battery-hidesystem=false
battery-show-menu=false
battery-style='graph'
battery-time=true
center-display=false
compact-display=false
cpu-display=true
cpu-graph-width=50
cpu-individual-cores=false
cpu-show-menu=true
cpu-show-text=true
cpu-style='digit'
disk-display=false
disk-show-menu=true
disk-style='digit'
disk-usage-style='bar'
fan-display=false
fan-sensor-file='/sys/class/hwmon/hwmon4/fan1_input'
fan-show-text=false
fan-style='digit'
freq-display=false
freq-show-menu=false
freq-style='digit'
gpu-display=false
icon-display=false
memory-buffer-color='#00ff82ff'
memory-cache-color='#aaf5d0ff'
memory-display=true
memory-graph-width=50
memory-refresh-time=2000
memory-show-menu=true
memory-show-text=true
memory-style='digit'
move-clock=false
net-display=false
show-tooltip=false
swap-display=false
swap-show-menu=false
swap-show-text=true
thermal-display=true
thermal-sensor-file='/sys/class/hwmon/hwmon3/temp1_input'
thermal-show-text=false
thermal-style='digit'
EOF

echo 'Done. You need to logout and login again to enable the extensions.'