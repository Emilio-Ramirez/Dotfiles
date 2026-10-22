# Bun — installed 2026-08-18. The bun.sh installer only patches ~/.zshrc,
# so add its bin directory to PATH for fish as well.
if test -d $HOME/.bun/bin
    fish_add_path -g $HOME/.bun/bin
end
