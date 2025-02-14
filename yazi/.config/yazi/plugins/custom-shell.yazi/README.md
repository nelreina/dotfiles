# Custom-shell.yazi

A yazi plugin to open your custom-shell as well as run your command commands through your yazi Shell, and also save your commands to history.
You can choose any shell and customise keybindings to run any command like nvim, lazygit, cowsay, etc. without inputting the command as well!

## Previews

https://github.com/AnirudhG07/custom-shell.yazi/assets/146579014/1cd6ab98-5b79-4ee8-b59a-dbee053edad5

## Requirements

Yazi version 0.3.0 or higher. And of course, your custom-shell as default shell.

# Installation

```bash
ya pack -a AnirudhG07/custom-shell

## For linux and MacOS
git clone https://github.com/AnirudhG07/custom-shell.yazi.git ~/.config/yazi/plugins/custom-shell.yazi

## For Windows
git clone https://github.com/AnirudhG07/custom-shell.yazi.git %AppData%\yazi\config\plugins\custom-shell.yazi
```

Windows user's should check the init.lua file to make sure the paths used are correct.

# Usage

## History Setup

Add the following to your `init.lua` file:

```lua
require("custom-shell"):setup({
    history_path = "default",
    save_history = true,
})
```

The `default` corresponds to `yazi_cmd_history` file in your `~/.config/yazi/plugins/custom-shell.yazi` directory(and similar for Windows). You can specify any other path if you like to save the history file elsewhere.

The `save_history` option is set to `true` by default, which will enable files to be saved to history. You can disable the behavior by setting it to `false`.

## Shell Selection

There are 2 ways you can set your custom-shell.

- The `auto` mode automatically sets the custom-shell to the value of `$SHELL` environment variable.
- The `shell_name` sets the custom-shell to the shell you want to use.

| **Mode** | **Description**                           |
| -------- | ----------------------------------------- |
| `auto`   | Automatically set custom-shell = `$SHELL` |
| `zsh`    | Set custom-shell = `zsh`                  |
| `bash`   | Set custom-shell = `bash`                 |
| `fish`   | Set custom-shell = `fish` <°))><          |
| `ksh`    | Set custom-shell = `ksh` or Kornshell     |

Similarly you can input the name of the shell you want to use.
<br>
These commands uses the below command to run the shells-

```bash
custom_shell -ic "command";exit
```

You can also set options about the processes to run. The `shell` API for yazi allows the following options:

1. Block: Custom-shell.yazi has default set to `true`.
2. Orphan: Custom-shell.yazi has default set to `false`.
3. Confirm: Custom-shell.yazi has default set to `true`.
4. Interactive: Custom-shell.yazi DOES NOT use it, since it is mutually exclusive with `confirm`.

To change these options, you can give the following arguments to the plugin:

1. `--no-block` or `-nb` to set block to `false`.
2. `--orphan` or `-o` to set orphan to `true`.
3. `--no-confirm` or `-nc` to set confirm to `false`.

Check the keybindings below to see how to set these options.

You can also add `--wait` or `-w` to make it wait for the user to press return key after executing the command. This allows the command output not to disappear immediately after exit and to stay readable on screen. Note that it is up to the command you run to decide whether to wait for user input or not, so this option may or may not be needed.

![wait argument demo](.assets/wait_demo.gif)

### Keybindings for Custom Shell

Add this to your `keymap.toml` file:

To use the `auto` mode, you can set the keymappings as:

```toml
[[manager.prepend_keymap]]
on = [ "'", ";" ]
run = "plugin custom-shell --args=auto"
desc = "custom-shell as default"
```

To choose a specific shell, you can set the keymappings as:

```toml
[[manager.prepend_keymap]]
on = [ "'", ";" ]
run = "plugin custom-shell --args=zsh"
desc = "custom-shell as default"
```

To set extra shell arguments, you can add them as:

```toml
[[manager.prepend_keymap]]
on = [ "'", ";" ]
run = "plugin custom-shell --args='zsh --no-block --orphan --no-confirm'"
# OR
# run = "plugin custom-shell --args='zsh -nb -o -nc'"
desc = "custom-shell as default with specified arguments"
```

To choose a specific shell and wait for user to press return key after executing the command:

```toml
[[manager.prepend_keymap]]
on = [ "'", ";" ]
run = "plugin custom-shell --args='zsh --wait'"
desc = "custom-shell as default, waits for user"
```

You can input any shell with their shortnames or full names like "Powershell" or "pwsh", "nushell" or "nu", "Kornshell" or "ksh", etc.

## Custom Commands

Custom-shell.yazi allows you to run your custom commands without inputting them inside yazi. You can set the shell through which you want to run your command as well. This also supports aliases.

To run a command, you can set the keymappings as:

```toml
[[manager.prepend_keymap]]
on = [ "l", "g" ]
run = "plugin custom-shell --args='custom auto lazygit'"
desc = "Run lazygit"
```

You can also run the commands with extra arguments as:

```toml
[[manager.prepend_keymap]]
on = [ "'", "1" ]
run = "plugin custom-shell --args='custom fish \"echo hi\" -o'"
desc = "Run echo hi"
```

```toml
[[manager.prepend_keymap]]
on = [ "'", "2" ]
run = "plugin custom-shell --args='custom nu \"tmux\"'"
desc = "Run tmux"
```

To make it wait with a custom command, specify the `--wait` or `-w` arg right after the `custom` keyword, like this:

```toml
[[manager.prepend_keymap]]
on = [ "'", "3" ]
run = "plugin custom-shell --args='custom --wait zsh \"echo hi\" -o'"
desc = "Run echo hi"
```

## History

Custom-shell saves the command you have run in a history file. It uses `fzf` to show history and run the selected command. You can set the keymappings to view the history as -

```toml
[[manager.prepend_keymap]]
on = [ "'", "h" ]
run = "plugin custom-shell --args=history"
desc = "Show Custom-shell history"
```

## Features

- Open your custom-shell as your default shell like zsh, <°))>< [fish](https://github.com/AnirudhG07/fish.yazi), bash, etc.
- Usage of aliases is supported.
- When using 'auto' mode, if you change your default shell, it will automatically change the custom-shell to the new default shell.
- If your shell runs extra commands like printing texts, taskwarrior, newsupdates, etc. when you open the shell, they will not hinder into it's functioning.
- Run custom commands without inputting them inside yazi.
- Set extra arguments for the processes to run.
- Save commands to history and execute them again.

## Explore Yazi

Yazi is an amazing, blazing fast terminal file manager, with a variety of plugins, flavors and themes. Check them out at [awesome-yazi](https://github.com/AnirudhG07/awesome-yazi) and the official [yazi webpage](https://yazi-rs.github.io/).

## Acknowledgement

This code is referenced from issue [#1206](https://github.com/sxyazi/yazi/issues/1206) and PR [#84](https://github.com/yazi-rs/yazi-rs.github.io/pull/84) I raised on the repositories. Thank you to the maintainers of sxyazi/yazi for the help.
