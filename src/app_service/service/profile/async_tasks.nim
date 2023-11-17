import os

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

type
  AsyncGetProfileShowcaseForContactTaskArg = ref object of QObjectTaskArg
    pubkey: string

const asyncGetProfileShowcaseForContactTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetProfileShowcaseForContactTaskArg](argEncoded)
  try:
    let response = status_accounts.getProfileShowcaseForContact(arg.pubkey)
    arg.finish(%* {
      "publicKey": arg.pubkey,
      "response": response,
      "error": nil,
    })
  except Exception as e:
    arg.finish(%* {
      "publicKey": arg.pubkey,
      "error": e.msg,
    })
