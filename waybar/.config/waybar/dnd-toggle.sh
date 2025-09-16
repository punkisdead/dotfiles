#!/bin/bash

DND_FILE="/tmp/mako-dnd-status"

if [ -f "$DND_FILE" ]; then
    makoctl mode -r do-not-disturb >/dev/null 2>&1
    rm "$DND_FILE"
    echo '{"text": "🔔", "tooltip": "Notifications enabled", "class": "enabled"}'
else
    makoctl mode -a do-not-disturb >/dev/null 2>&1
    touch "$DND_FILE"
    echo '{"text": "🔕", "tooltip": "Do Not Disturb", "class": "dnd"}'
fi