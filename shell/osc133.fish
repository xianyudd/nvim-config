# OSC 133 prompt start for Neovim shell integration (fish 3.x).
# Source only when $NVIM is set. Does not wrap or re-run commands.

function __nvim_osc133_prompt --on-event fish_prompt --description 'OSC 133 prompt mark for Neovim'
    printf '\e]133;A\a'
end
