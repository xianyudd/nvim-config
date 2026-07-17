# OSC 133 prompt start for Neovim shell integration.
# Only intended to be sourced when running inside :terminal ($NVIM set).
# Does not wrap or re-run commands.

__nvim_osc133_prompt() {
  printf '\033]133;A\007'
}

# Prepend without clobbering existing PROMPT_COMMAND.
case ";${PROMPT_COMMAND};" in
  *";__nvim_osc133_prompt;"*) ;;
  *)
    if [ -n "${PROMPT_COMMAND-}" ]; then
      PROMPT_COMMAND="__nvim_osc133_prompt;${PROMPT_COMMAND}"
    else
      PROMPT_COMMAND="__nvim_osc133_prompt"
    fi
    ;;
esac
