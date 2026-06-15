#!/bin/bash

# Batman Arkham Power Menu Script 🦇

echo -en "\0prompt\x1f⚡ BATMAN POWER MENU ⚡\n"
echo -en "󰌾 Lock\0icon\x1f🔒\n"
echo -en "󰤄 Suspend\0icon\x1f💤\n"
echo -en "󰜉 Reboot\0icon\x1f🔄\n"
echo -en "󰐥 Shutdown\0icon\x1f⛔\n"
echo -en "󰗽 Logout\0icon\x1f🚪\n"

case "$1" in
    "󰌾 Lock")
        hyprctl dispatch exit
        ;;
    "󰤄 Suspend")
        systemctl suspend
        ;;
    "󰜉 Reboot")
        systemctl reboot
        ;;
    "󰐥 Shutdown")
        systemctl poweroff
        ;;
    "󰗽 Logout")
        hyprctl dispatch exit
        ;;
esac

chmod +x ~/scripts/powermenu.sh
