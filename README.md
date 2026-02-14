# HyprMenu

A modern, customizable menu for Hyprland (and other WMs) built with Flutter.

## Configuration

HyprMenu reads configuration from `~/.config/hyprmenu/config.json`.
If the file does not exist, a default one will be created on the first run.

### Default Config (`config.json`)

```json
{
  "theme": {
    "primaryColor": "#F38BA8",
    "backgroundColor": "#1E1E2E"
  },
  "window": {
    "width": 400,
    "height": 1000
  },
  "directories": [
    { "label": "Home", "path": "~/", "icon": "home" },
    { "label": "Downloads", "path": "~/Downloads", "icon": "download" }
  ],
  "apps": [
    { "name": "Browser", "command": "firefox", "icon": "web" },
    { "name": "Discord", "command": "discord", "icon": "chat" },
    { "name": "Spotify", "command": "spotify", "icon": "music_note" },
    { "name": "Terminal", "command": "kitty", "icon": "terminal" }
  ]
}
```

### Supported Icons
- `home`, `download`, `folder`, `image`, `movie`, `music_note`, `terminal`, `web`, `chat`, `code`, `search`, `article`.

## Integration

### Waybar

You can add a custom module to Waybar to toggle HyprMenu.

**1. Create a toggle script (`~/.config/hyprmenu/launch.sh`):**
```bash
#!/bin/bash
# Check if hyprmenu is running
if pgrep -x "hyprmenu" > /dev/null; then
    # If running, kill it (toggle off)
    pkill -x hyprmenu
else
    # If not running, start it
    /path/to/your/hyprmenu/build/linux/x64/release/bundle/hyprmenu
fi
```
Make it executable: `chmod +x ~/.config/hyprmenu/launch.sh`

**2. Add module to `waybar/config`:**
```json
"custom/menu": {
    "format": "",
    "on-click": "~/.config/hyprmenu/launch.sh",
    "tooltip": false
}
```

### Hyprland Window Rules

To ensure the menu floats, has no border, and stays fixed in position (e.g., top right):

Add this to `~/.config/hypr/hyprland.conf`:

```ini
# Float the window
windowrulev2 = float,class:^(hyprmenu)$

# Remove borders and shadows
windowrulev2 = noborder,class:^(hyprmenu)$
windowrulev2 = noshadow,class:^(hyprmenu)$

# Position it (Top Right example)
# y-offset 10px, x-offset 10px from right
windowrulev2 = move 100%-410 10,class:^(hyprmenu)$

# Size it (matches your config)
windowrulev2 = size 400 1000,class:^(hyprmenu)$

# Animation (Slide in from right)
windowrulev2 = animation slide right,class:^(hyprmenu)$

# Keep it on top
windowrulev2 = pin,class:^(hyprmenu)$
```

## Building

```bash
flutter build linux
```
The executable will be in `build/linux/x64/release/bundle/hyprmenu`.
