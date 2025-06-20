if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias l='eza'
alias ll='l --group --header --group-directories-first --long'
alias le='l --group --header --group-directories-first --long --git --git-ignore'
alias lee='l --group --header --group-directories-first --long --extended'
alias lt2='l --group --header --group-directories-first --tree --level 2'
alias lt3='l --group --header --group-directories-first --tree --level 3'
alias le2='l --group --header --group-directories-first --long --git --git-ignore --tree --level 2'
alias le3='l --group --header --group-directories-first --long --git --git-ignore --tree --level 3'
alias le4='l --group --header --group-directories-first --long --git --git-ignore --tree --level 4'
alias lc='l --group --header --group-directories-first --across'
alias lo='l --group --header --group-directories-first --oneline'
alias lg="lazygit"
alias vim='nvim'

#For autocomplete #
# Unbind the default Ctrl+F
bind -e \cf

# Bind Cmd+Enter to accept-autosuggestion
bind \e\r accept-autosuggestion

function create_env
    python3 -m venv .venv
    source .venv/bin/activate.fish
end


set -gx NVM_DIR "$HOME/.nvm"

bass source /opt/homebrew/opt/nvm/nvm.sh

# D1 database query shortcut
alias d1q='npx wrangler d1 execute DB --local --command'
