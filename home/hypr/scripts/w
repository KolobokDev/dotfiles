#!/bin/sh

if pgrep -x quickshell > /dev/null; then
    pkill -x quickshell
else
    quickshell -p ~/.config/quickshell > /tmp/quickshell.log 2>&1 &
fi
