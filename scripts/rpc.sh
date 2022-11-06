#!/usr/bin/env bash
# vim: set ft=sh:

RPC_PORT="${RPC_PORT:-8545}"
RPC_HOST="${RPC_HOST:-127.0.0.1}"

METHOD="$1"
shift
PARAMS=("$@")

if [[ -z "${METHOD}" ]]; then
    echo "No method specified!" >&2
    exit 1
fi
if [[ -n "${PARAMS}" ]]; then
    PARAMS_STR=$(printf '%s\",\"' "${PARAMS[@]}")
    # Params are a nested array because of a bug in nim-json-rpc.
    # https://github.com/status-im/nim-json-rpc/issues/90
    PARAMS_STR="[\"${PARAMS_STR%%\",\"}\"]"
else
    PARAMS_STR=''
fi

PAYLOAD="{
  \"id\": 1,
  \"jsonrpc\": \"2.0\",
  \"method\": \"${METHOD}\",
  \"params\": [${PARAMS_STR}]
}"

# The jq script checks if error exists and adjusts exit code.
curl --request POST \
    --silent \
    --show-error \
    --fail-with-body \
    --header 'Content-type:application/json' \
    --data "${PAYLOAD}" \
    "${RPC_HOST}:${RPC_PORT}" | \
    jq -e '., if .error != null then null|halt_error(2) else halt end'
