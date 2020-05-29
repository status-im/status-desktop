import NimQml
import eventemitter
import strformat
import json

import ../../status/libstatus/mailservers as status_mailservers
import ../../signals/types
import view
import "../../status/libstatus/types" as status_types
import ../../status/profile

import ../../status/status

type ProfileController* = object
  view*: ProfileView
  variant*: QVariant
  status*: Status

proc newController*(status: Status): ProfileController =
  result = ProfileController()
  result.status = status
  result.view = newProfileView()
  result.variant = newQVariant(result.view)

proc delete*(self: ProfileController) =
  delete self.view
  delete self.variant

proc init*(self: ProfileController, account: Account) =
  let profile = account.toProfileModel()
  self.view.setNewProfile(profile)

  var mailservers = status_mailservers.getMailservers()
  for mailserver_config in mailservers:
    let mailserver = MailServer(name: mailserver_config[0], endpoint: mailserver_config[1])
    self.view.addMailServerToList(mailserver)

  self.view.addContactToList(Contact(name: "username1", address: "0x12345"))
  self.view.addContactToList(Contact(name: "username2", address: "0x23456"))
  self.view.addContactToList(Contact(name: "username3", address: "0x34567"))
