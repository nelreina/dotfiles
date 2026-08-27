# wormhole.yazi

Send and receive files from [Yazi](https://github.com/sxyazi/yazi) with [magic-wormhole](https://github.com/magic-wormhole/magic-wormhole) — a short spoken code, end-to-end encrypted, to someone with **no shared account, no LAN, and no pairing**.

Yazi has plugins for croc, LocalSend, KDE Connect and Telegram, but nothing for magic-wormhole. This fills that gap.

## Requirements

- Yazi ≥ 26.8.15
- [`magic-wormhole`](https://github.com/magic-wormhole/magic-wormhole) in `$PATH` — `brew install magic-wormhole`
- `tar` — only used when sending a multi-file selection

## Installation

```sh
ya pkg add nelreina/wormhole
```

Or clone manually:

```sh
git clone https://github.com/nelreina/wormhole.yazi ~/.config/yazi/plugins/wormhole.yazi
```

## Usage

Add to your `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on   = [ "W", "s" ]
run  = "plugin wormhole -- send"
desc = "Send via magic-wormhole"

[[mgr.prepend_keymap]]
on   = [ "W", "r" ]
run  = "plugin wormhole -- receive"
desc = "Receive via magic-wormhole"
```

> Note the uppercase `W`. Lowercase `w` is Yazi's preset `tasks:show`. Uppercase `W` is bound only in the *input* layer (a text motion), so it is free in the manager layer.

## Behaviour

### Send — `W s`

| Selection | What happens |
|---|---|
| nothing selected | the hovered file or directory is sent |
| one file | sent directly |
| one directory | sent directly — wormhole zips it itself |
| several items | bundled into `/tmp/wormhole-<hash>.tar.gz`, sent, then the tarball is deleted |

`wormhole send` accepts **exactly one path** — passing two fails with `Got unexpected extra argument`. That single constraint is why bundling exists. The archive is built with `tar -C <cwd>` over basenames, so the receiver doesn't unpack a deep directory chain.

### Receive — `W r`

Prompts for the code, then receives into the directory you are currently browsing. Uses `--accept-file` so it doesn't ask for confirmation a second time, and trims whitespace around a pasted code.

Both actions hand the real terminal over with `ui.hide()`, so wormhole's code phrase, verification string and progress bar render normally; the TUI comes back when the transfer ends.

## Notes

- The QR code (`wormhole send --qr`) is deliberately not enabled — it costs roughly 25 terminal rows on every send. If you want it, add `"--qr"` to the args in `send()`.
- To always verify the peer before transferring, add `"--verify"` the same way.

## License

MIT
