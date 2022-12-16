#!/bin/bash

case "$1" in
	docked)
		workspaces=$(swaymsg -pt get_workspaces)
		last_focused=$(echo "$workspaces" | grep focused | grep -Po '\d+')
		swaymsg workspace 10, move workspace to eDP-1
		for i in 1 2 3 4 5 6 7; do
			workspaceinfo=$(echo "$workspaces" | grep -A3 -P "Workspace $i\b")
			[ $? -eq 0 ] || continue
			(echo "$workspaceinfo" | grep -q null) || swaymsg workspace $i, move workspace to DP-1
		done
		swaymsg workspace $last_focused
		;;
esac
