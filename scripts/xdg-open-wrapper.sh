#!/usr/bin/env sh
# Avoid 'undefined symbol: rl_trim_arg_from_keyseq' from newer Bash.
unset LD_LIBRARY_PATH
# Remove AppImage path to avoid recursive loop of xdg-open executions.
PATH=$(echo "${PATH}" | tr ':' '\n' | grep -v "${APPDIR}" | tr '\n' ':')
exec xdg-open "$@"
