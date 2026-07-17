# OSC 133 prompt-start compatibility for fish 3.x in Neovim terminals.
# fish 4+ provides native OSC 133 shell integration.

if not set -q NVIM; or test -z "$NVIM"
    return
end

set -l fish_major (string split . -- $version)[1]
if test "$fish_major" -ge 4
    return
end

if functions -q __nvim_osc133_prompt
    return
end

function __nvim_osc133_prompt --on-event fish_prompt --description 'OSC 133 prompt mark for Neovim'
    printf '\e]133;A\a'
end
