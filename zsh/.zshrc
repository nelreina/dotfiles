# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/nelsonreina/.zsh/completions:"* ]]; then export FPATH="/Users/nelsonreina/.zsh/completions:$FPATH"; fi
# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export NRTOOLS="$HOME/Dropbox/tools-scripts"
export FLUTTER="$HOME/Documents/SRC/SDK/flutter/bin"
export ANDROID_PT=$HOME/Library/Android/sdk/platform-tools

export PYTHON="/usr/local/bin/python3"
export PATH=$HOME/bin:/usr/local/bin:$PYTHON:$NRTOOLS:$FLUTTER:$ANDROID_PT:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=/usr/local/git/bin:$PATH
export PATH="$HOME/.bun/bin:$PATH"


export ZSH="$HOME/.oh-my-zsh"
export VISUAL=nvim;
export EDITOR=nvim;
export ELIXIR_EDITOR="code --goto __FILE__:__LINE__"
# export ERL_AFLAGS="-kernel shell_history enabled"

# ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="apple"

plugins=(
	copyfile
	copypath
  git 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  fast-syntax-highlighting 
  zsh-autocomplete
)
# plugins=(
# 	docker
# 	docker-compose
# 	git
# 	history
# 	history-substring-search
# 	last-working-dir
# 	macos
# 	python
# 	web-search
#   fzf
#   fzf-tab
# 	z
# )
#
source $ZSH/oh-my-zsh.sh

source $HOME/.zsh_aliases

HISTSIZE=20000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups

zstyle ':completion:*' menu no

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"


eval "$(starship init zsh)"


# pnpm
export PNPM_HOME="/Users/nelsonreina/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Add JBang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(fzf --zsh)"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

. "/Users/nelsonreina/.deno/env"
# Initialize zsh completions (added by deno install script)
autoload -Uz compinit
compinit
