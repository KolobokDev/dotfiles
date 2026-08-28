#!/bin/bash

if pgrep -x waybar > /dev/null; then
    pkill -x waybar
else
    waybar > /tmp/waybar.log 2>&1 &
fi
