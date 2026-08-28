#!/bin/bash

STATE="/tmp/waybar-clockweather-state"
WEATHER="/tmp/waybar-clockweather-weather"
WEATHER_TIME="/tmp/waybar-clockweather-time"

[ ! -f "$STATE" ] && echo 0 > "$STATE"

if [ "$1" = "toggle" ]; then
    if [ "$(cat "$STATE")" = "0" ]; then
        echo 1 > "$STATE"
    else
        echo 0 > "$STATE"
    fi
    exit 0
fi

# Обновляем погоду раз в 15 минут
NOW=$(date +%s)

if [ ! -f "$WEATHER_TIME" ] || \
   [ $((NOW - $(cat "$WEATHER_TIME" 2>/dev/null || echo 0))) -ge 900 ]; then

    NEW_WEATHER=$(curl -s --max-time 5 \
        'https://wttr.in/?format=%c+%t' 2>/dev/null | tr -d '\n')

    if [ -n "$NEW_WEATHER" ]; then
        echo "$NEW_WEATHER" > "$WEATHER"
        echo "$NOW" > "$WEATHER_TIME"
    fi
fi

STATE_VALUE=$(cat "$STATE")

if [ "$STATE_VALUE" = "0" ]; then

    echo "{\"text\":\" $(date '+%H:%M')\"}"

else

    WEATHER_VALUE=$(cat "$WEATHER" 2>/dev/null)

    [ -z "$WEATHER_VALUE" ] && WEATHER_VALUE="󰖐 --"

    echo "{\"text\":\"󰃭 $(date '+%H:%M %d.%m.%Y')  $WEATHER_VALUE\"}"

fi
