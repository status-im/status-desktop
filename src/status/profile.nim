import json, eventemitter
import libstatus/types
import profile/profile
import libstatus/core as libstatus_core
import libstatus/accounts as status_accounts

type
  ProfileModel* = ref object

proc newProfileModel*(): ProfileModel =
  result = ProfileModel()

proc logout*(self: ProfileModel) =
  discard status_accounts.logout()
