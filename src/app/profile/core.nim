import NimQml
import json
import "../../status/core" as status
import ../signals/types
import profileView
import "../../status/types" as status_types

type ProfileController* = ref object of SignalSubscriber
  view*: ProfileView
  variant*: QVariant

proc newController*(): ProfileController =
  result = ProfileController()
  result.view = newProfileView()
  result.variant = newQVariant(result.view)

proc delete*(self: ProfileController) =
  delete self.view
  delete self.variant

proc init*(self: ProfileController, account: Account) =
  self.view.setUsername(account.name)
  self.view.setIdenticon(account.photoPath)
