# OSC 133 prompt start for Neovim shell integration.
# Source only when $NVIM is set. Does not wrap or re-run commands.

if [ -z "${NVIM-}" ]; then
  return 0 2>/dev/null || exit 0
fi

if type __nvim_osc133_prompt >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

# Skip if PROMPT_COMMAND already looks like shell-integration / OSC 133
if printf '%s' "${PROMPT_COMMAND-}" | grep -Eq '133|__vte_prompt|__vte_osc|shell_integration|__nvim_osc133_prompt'; then
  return 0 2>/dev/null || exit 0
fi

__nvim_osc133_prompt() {
  printf '\033]133;A\007'
}

if [ -n "${PROMPT_COMMAND-}" ]; then
  PROMPT_COMMAND="__nvim_osc133_prompt;${PROMPT_COMMAND}"
else
  PROMPT_COMMAND="__nvim_osc133_prompt"
fi
