# CleanStart

A macOS utility that resets your workspace to a clean, consistent state by closing running apps, launching your preferred utilities, and clearing clutter.

## What It Does

- **Kills foreground apps** — Terminates all running foreground applications
- **Launches utilities** — Starts your preferred background utilities (In My case):
  - PasteBot, SnippetsLab, Alfred 5, Dash, Mona, Moom, Keyboard Maestro Engine, Bartender 6
- **Cleans Finder** — Clears recent items/folders and closes all windows
- **Starts SSH agent** — Loads SSH keys from keychain
- **Sets volume** — Restores system volume to 40%

## Requirements

- macOS
- Accessibility permissions (the app will prompt for access on first run)

## Installation

1. Download `CleanStart.app` from [Releases](../../releases)
2. Move to `/Applications`
3. Grant Accessibility permissions when prompted

## Building from Source

```bash
./build.sh
```

Requires a valid Developer ID certificate for code signing and notarization.

## License

Copyright © 2026 Gary Ash. All rights reserved.
