# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's Included

| Package | Description |
|---------|-------------|
| `alacritty` | Alacritty terminal emulator |
| `backgrounds` | Wallpaper collection |
| `doom` | Doom Emacs configuration |
| `dunst` | Notification daemon (X11) |
| `ghostty` | Ghostty terminal emulator |
| `gtk-3.0` | GTK3 theme settings |
| `hypr` | Hyprland, Hypridle, Hyprlock, Hyprpaper |
| `i3` | i3 window manager |
| `kitty` | Kitty terminal emulator |
| `neofetch` | System info display |
| `picom` | X11 compositor |
| `polybar` | Status bar (X11) |
| `rofi` | Application launcher |
| `swaync` | Notification center (Wayland) |
| `Thunar` | File manager custom actions |
| `waybar` | Status bar (Wayland) |
| `zsh` | Zsh shell configuration |

## Prerequisites

Install GNU Stow:

```bash
# Debian/Ubuntu
sudo apt install stow

# Arch
sudo pacman -S stow

# Fedora
sudo dnf install stow
```

## Usage

Clone this repository to your home directory:

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
```

### Stow a package

Symlink a configuration to `~/.config` (or `~` for zsh):

```bash
stow <package>
```

Examples:

```bash
stow i3        # Symlinks i3 config to ~/.config/i3
stow zsh       # Symlinks .zshrc to ~/.zshrc
stow kitty     # Symlinks kitty config to ~/.config/kitty
```

### Stow multiple packages

```bash
stow i3 polybar picom rofi   # X11 setup
stow hypr waybar swaync      # Wayland setup
```

### Remove a package

```bash
stow -D <package>
```

### Re-stow (useful after updates)

```bash
stow -R <package>
```

### Preview changes (dry run)

```bash
stow -n -v <package>
```

### Stow everything

```bash
stow */
```

## How It Works

GNU Stow creates symlinks from the dotfiles directory to your home directory. Each package folder mirrors the structure relative to `~`. For example:

```
dotfiles/
└── kitty/
    └── .config/
        └── kitty/
            └── kitty.conf
```

Running `stow kitty` creates:

```
~/.config/kitty/kitty.conf -> ~/dotfiles/kitty/.config/kitty/kitty.conf
```

## Notes

- The repository contains configurations for both X11 (i3, polybar, picom, dunst) and Wayland (Hyprland, waybar, swaync)
- Wallpapers are stored at 3440x1440 resolution
- Backup existing configs before stowing to avoid conflicts
