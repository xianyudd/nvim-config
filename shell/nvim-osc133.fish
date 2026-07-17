# nvim-term-yank managed loader
# Load the Neovim OSC 133 compatibility hook only in Neovim terminals.

if set -q NVIM; and test -n "$NVIM"
    set -l hook "$HOME/.config/nvim/shell/osc133.fish"
    if test -r $hook
        source $hook
    end
end
