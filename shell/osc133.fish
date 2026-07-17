# OSC 133 prompt start for Neovim shell integration (fish 3.x).
# Source only when $NVIM is set. Skip if fish already emits OSC 133 natively (4+).
# Does not wrap or re-run commands.

if not set -q NVIM
    return
end

# fish 4+ ships native shell integration (OSC 133); do not double-inject.
set -l _nvim_fish_ver (fish --version | string match -r '[0-9]+\.[0-9]+' | head -n1)
set -l _nvim_fish_major (string split . -- $_nvim_fish_ver)[1]
if test -n "$_nvim_fish_major"; and test "$_nvim_fish_major" -ge 4 2>/dev/null
    return
end

# Already installed (re-source / double conf.d)
if functions -q __nvim_osc133_prompt
    return
end

function __nvim_osc133_prompt --on-event fish_prompt --description 'OSC 133 prompt mark for Neovim'
    printf '\e]133;A\a'
end
