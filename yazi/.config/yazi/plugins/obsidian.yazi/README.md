# obsidian.yazi

Obsidian vault integration for [Yazi](https://yazi-rs.github.io/) file manager.

Browse backlinks, tags, daily notes, and wikilinks without leaving the terminal.

## Features

| Key     | Command      | Description                                    |
| ------- | ------------ | ---------------------------------------------- |
| `o, o`  | Menu         | Command palette with all features              |
| `o, b`  | Backlinks    | Find all files linking to current note via `[[]]` |
| `o, t`  | Tags         | Browse all vault tags sorted by count          |
| `o, d`  | Daily Note   | Create or open today's daily note              |
| `o, l`  | Links        | Follow wikilinks from current file             |
| `o, s`  | Search       | Full-text search across vault                  |

## Requirements

- [Yazi](https://yazi-rs.github.io/) (latest)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`)

## Setup

1. Copy or symlink to `~/.config/yazi/plugins/obsidian.yazi/`

2. Edit `VAULT_PATH` in `main.lua` to point to your vault

3. Add keybindings to `~/.config/yazi/keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = ["o", "o"]
run = "plugin obsidian"
desc = "Obsidian: command menu"

[[manager.prepend_keymap]]
on = ["o", "b"]
run = "plugin obsidian -- backlinks"
desc = "Obsidian: backlinks"

[[manager.prepend_keymap]]
on = ["o", "t"]
run = "plugin obsidian -- tags"
desc = "Obsidian: tags"

[[manager.prepend_keymap]]
on = ["o", "d"]
run = "plugin obsidian -- daily"
desc = "Obsidian: daily note"

[[manager.prepend_keymap]]
on = ["o", "l"]
run = "plugin obsidian -- links"
desc = "Obsidian: follow wikilinks"

[[manager.prepend_keymap]]
on = ["o", "s"]
run = "plugin obsidian -- search"
desc = "Obsidian: search vault"
```

## License

MIT
