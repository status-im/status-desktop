import NimQml
import json
import "../../status/core" as status
import ../signals/types
import profileView

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

proc init*(self: ProfileController, accounts: string) =
    var chatAccount = parseJSON(accounts)[1]

    self.view.setUsername(chatAccount["name"].str)
    self.view.setIdenticon(chatAccount["photo-path"].str)
