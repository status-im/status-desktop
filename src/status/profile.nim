import json
import libstatus/types
import profile/profile
import libstatus/core as libstatus_core
import libstatus/accounts as status_accounts
import libstatus/settings as status_settings
import ../eventemitter

type
  ProfileModel* = ref object

proc newProfileModel*(): ProfileModel =
  result = ProfileModel()

proc logout*(self: ProfileModel) =
  discard status_accounts.logout()

proc getLinkPreviewWhitelist*(self: ProfileModel): JsonNode =
  result = status_settings.getLinkPreviewWhitelist()
