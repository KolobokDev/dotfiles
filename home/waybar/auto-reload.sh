while inotifywait -e close_write ~/.config/waybar; do killall waybar; waybar & done
