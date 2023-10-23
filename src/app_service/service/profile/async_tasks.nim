import os, parseutils

include ../../common/json_utils
include ../../../app/core/tasks/common

import ../../../backend/accounts as status_accounts

const asyncGetProfileShowcasePreferencesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)
  try:
    let response = status_accounts.getProfileShowcasePreferences()
    arg.finish(%* {
      "response": response,
      "error": nil,
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })
