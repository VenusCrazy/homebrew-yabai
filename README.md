# homebrew-yabai

Homebrew tap for the [macOS 27 (Golden Gate) fork of yabai](https://github.com/VenusCrazy/yabai).

Upstream yabai does not yet support macOS 27. This tap builds the fork, which adds:

- macOS 27 scripting-addition offsets (Apple Silicon / arm64e)
- scripting-addition load fix (the `-arm64e_preview_abi` boot-arg is not required on macOS 14.4+)
- main-binary macOS 27 recognition (treated as Tahoe-compatible, so Mission Control observation, space/window notifications and the sub-level query work)

## Install

```sh
brew install venuscrazy/yabai/yabai
```

To build the latest commit instead of the tagged release:

```sh
brew install --HEAD venuscrazy/yabai/yabai
```

## After installing

1. Grant Accessibility to the installed binary in
   *System Settings → Privacy & Security → Accessibility*.

2. Start the service:

   ```sh
   yabai --start-service
   ```

3. Load the scripting addition once:

   ```sh
   sudo "$(command -v yabai)" --load-sa
   ```

4. Configure re-injection. macOS 27's Dock does not auto-load the scripting
   addition, so add a passwordless sudoers rule and two lines to `yabairc`:

   ```sh
   BIN="$(command -v yabai)"
   echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 "$BIN" | cut -d ' ' -f 1) $BIN --load-sa"
   sudo visudo -f /private/etc/sudoers.d/yabai   # paste the printed line
   ```

   Then add to the top of `~/.config/yabai/yabairc` (using the absolute path):

   ```
   yabai -m signal --add event=dock_did_restart action="sudo /path/to/yabai --load-sa"
   sudo /path/to/yabai --load-sa
   ```

See [`doc/BUILD-macOS-27.md`](https://github.com/VenusCrazy/yabai/blob/master/doc/BUILD-macOS-27.md)
for the complete guide and troubleshooting.

## Migrating back to upstream

Once `asmvik` ships official macOS 27 support:

```sh
brew uninstall yabai
brew untap venuscrazy/yabai
brew install asmvik/formulae/yabai
```

then re-grant Accessibility (the official release is signed with a different
certificate) and update the sudoers rule to the new binary path.

## Uninstall

```sh
brew uninstall yabai
sudo rm -f /private/etc/sudoers.d/yabai
```
