#!/bin/bash

# Toggle DND mode
swaync-client -d -t

# Get current DND status
DND_STATUS=$(swaync-client -D)

if [ "$DND_STATUS" = "true" ]; then
    echo '{"text": "🔕", "tooltip": "Do Not Disturb", "class": "dnd"}'
else
    echo '{"text": "🔔", "tooltip": "Notifications enabled", "class": "enabled"}'
fi