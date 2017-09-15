#!/bin/bash
dconf write /org/gnome/mutter/keybindings/toggle-tiled-left "['']"
dconf write /org/gnome/mutter/keybindings/toggle-tiled-right "['']"

dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:swapcaps']"
dconf write /org/gnome/desktop/wm/preferences/num-workspaces 9

dconf write /org/gnome/desktop/wm/keybindings/close "['<Shift><Super>q']"
dconf write /org/gnome/desktop/wm/keybindings/cycle-windows "['<Super>Right']"
dconf write /org/gnome/desktop/wm/keybindings/cycle-windows-backward "['<Super>Left']"

for i in {1..9}; do
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-$i "['<Super>$i']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-$i "['<Shift><Super>$i']"
done

