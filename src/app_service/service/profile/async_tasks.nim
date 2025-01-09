import os

include ../../common/json_utils
include ../../../app/core/tasks/common

import ../../../backend/accounts as status_accounts

proc asyncGetProfileShowcasePreferencesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)
  try:
    let response = status_accounts.getProfileShowcasePreferences()
    arg.finish(%*{"response": response, "error": ""})
  except Exception as e:
    arg.finish(%*{"error": e.msg})

type SaveProfileShowcasePreferencesTaskArg = ref object of QObjectTaskArg
  preferences: ProfileShowcasePreferencesDto

proc saveProfileShowcasePreferencesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SaveProfileShowcasePreferencesTaskArg](argEncoded)
  try:
    let response =
      status_accounts.setProfileShowcasePreferences(arg.preferences.toJsonNode())
    arg.finish(%*{"response": response, "error": ""})
  except Exception as e:
    arg.finish(%*{"error": e.msg})
