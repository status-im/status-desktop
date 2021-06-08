import json
import types
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

proc storeIdentityImage*(self: ProfileModel, keyUID: string, imagePath: string, aX, aY, bX, bY: int): IdentityImage =
  result = status_accounts.storeIdentityImage(keyUID, imagePath, aX, aY, bX, bY)

proc getIdentityImage*(self: ProfileModel, keyUID: string): IdentityImage =
  result = status_accounts.getIdentityImage(keyUID)

proc deleteIdentityImage*(self: ProfileModel, keyUID: string): string =
  result = status_accounts.deleteIdentityImage(keyUID)
