![](.github/projectLogo.png)

# CleanStart

A macOS utility that resets my workspace to a clean, consistent state — closing whatever is
running, relaunching the handful of things I actually want, and tidying up the leftovers.

It is a single AppleScript packaged as a signed, notarized `.app`. It is written for my own
machine and my own app lineup; treat it as a starting point rather than a general-purpose tool.

## What It Does

Steps run in this order:

1. **Mutes output** — silences the speakers so nothing chirps during setup
2. **Waits for Accessibility permission** — opens System Settings → Privacy & Security →
   Accessibility if the applet has not been granted assistive access
3. **Kills foreground apps** — `killall`s every non-background process except CleanStart itself
4. **Launches and hides background utilities** — Pastebot, Mona, and Moom, each started hidden
   if it is not already running (12-second timeout on each wait, so a launch that never
   completes cannot hang the run)
5. **Starts the SSH agent** — runs `ssh-add --apple-load-keychain` when no agent is present, so
   Git commit signing works without a prompt
6. **Clears the Pastebot clipboard** — Edit → Clear Clipboard, confirming the sheet
7. **Preps SnippetsLab** — launches it if it is not running, then closes its windows so it sits
   in the background (12-second timeout on each wait, so a slow launch cannot hang the run)
8. **Refreshes Mona** — File → Refresh, then scrolls the timeline to the top
9. **Cleans up Slack** — walks every workspace marking All Unreads as read, then closes the window
10. **Configures Finder** — opens the home folder, then collapses, centers at 1100×1000 and
    closes every open window, reopens Downloads in list view with the visible columns set to
    Size, Kind, Date Created and Date Modified, and clears Recent Items and Recent Folders
11. **Restores volume** — sets output volume back to 40%
12. **Quits** — the applet terminates itself once the run handler finishes

Every step after the app launches is wrapped in its own error handler, so an app you do not have
installed is skipped rather than aborting the run.

CleanStart is an agent app (`LSUIElement`), so it never takes a Dock tile or a menu bar while it
works. Combined with the explicit quit, it leaves nothing behind once setup is done.

## Requirements

- macOS on Apple silicon — the build strips the `x86_64` slice
- Accessibility permission for `CleanStart.app` (the app opens the settings pane on first run)
- The apps it drives, if you want those steps to do anything: Pastebot, Mona, Moom, SnippetsLab,
  Slack

To change which utilities get launched, edit `appsList` at the top of `CleanStart.applescript`.

## Installation

1. Download `CleanStart.app` from [Releases](../../releases)
2. Move it to `/Applications`
3. Grant Accessibility permission when prompted

## Building from Source

```bash
./build.sh
```

The script compiles the AppleScript with `osacompile`, swaps in `Info.plist` and `AppIcon.icns`,
strips the Intel slice, then signs, notarizes, and staples the bundle. It needs:

- A **Developer ID Application** certificate in the login keychain
- A `notarytool` keychain profile named `notary-profile`:

  ```bash
  xcrun notarytool store-credentials notary-profile \
      --apple-id <your-apple-id> --team-id <your-team-id>
  ```

## License

[MIT](LICENSE.md) — Copyright © 2026 Gary Ash.
