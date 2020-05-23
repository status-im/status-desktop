import NimQml
import strformat
import json
import "../../status/core" as status
import ../../status/mailservers as status_mailservers
import ../signals/types
import profileView
import "../../status/types" as status_types
import ../../models/profile

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
  let profile = account.toProfileModel()
  self.view.setNewProfile(profile)

  var mailservers = status_mailservers.getMailservers()
  for mailserver in mailservers:
    self.view.addMailserverToList(mailserver[0], mailserver[1])
