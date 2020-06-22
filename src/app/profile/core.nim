import NimQml
import json, eventemitter
import strutils
import ../../status/libstatus/mailservers as status_mailservers
import ../../signals/types
import "../../status/libstatus/types" as status_types
import ../../status/libstatus/settings as status_settings
import ../../status/profile/[profile, mailserver]
import ../../status/contacts
import ../../status/status
import ../../status/chat as status_chat
import ../../status/chat/chat
import view

type ProfileController* = ref object of SignalSubscriber
  view*: ProfileView
  variant*: QVariant
  status*: Status

proc newController*(status: Status): ProfileController =
  result = ProfileController()
  result.status = status
  result.view = newProfileView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: ProfileController) =
  delete self.variant
  delete self.view

proc init*(self: ProfileController, account: Account) =
  let profile = account.toProfileModel()

  # (rramos) TODO: I added this because I needed the public key
  # Ideally, this module should call getSettings once, and fill the 
  # profile with all the information comming from the settings.
  let response = status_settings.getSettings()
  let pubKey = parseJSON($response)["result"]["public-key"].getStr
  let mnemonic = parseJSON($response)["result"]["mnemonic"].getStr
  profile.id = pubKey

  self.view.setNewProfile(profile)
  self.view.setMnemonic(mnemonic)

  var mailservers = status_mailservers.getMailservers()
  for mailserver_config in mailservers:
    let mailserver = MailServer(name: mailserver_config[0], endpoint: mailserver_config[1])
    self.view.addMailServerToList(mailserver)

  let contacts = self.status.contacts.getContacts()
  self.status.chat.updateContacts(contacts)
  self.view.setContactList(contacts)

  self.status.events.on("contactAdded") do(e: Args):
    let contacts = self.status.contacts.getContacts()
    self.view.setContactList(contacts)

  self.status.events.on("contactRemoved") do(e: Args):
    let contacts = self.status.contacts.getContacts()
    self.view.setContactList(contacts)

method onSignal(self: ProfileController, data: Signal) =
  let msgData = MessageSignal(data);
  if msgData.contacts.len > 0:
    # TODO: view should react to model changes
    self.status.chat.updateContacts(msgData.contacts)
    self.view.updateContactList(msgData.contacts)
