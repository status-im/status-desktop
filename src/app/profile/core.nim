import NimQml
import json
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
  delete self.view
  delete self.variant

proc init*(self: ProfileController, account: Account) =
  let profile = account.toProfileModel()

  # (rramos) TODO: I added this because I needed the public key
  # Ideally, this module should call getSettings once, and fill the 
  # profile with all the information comming from the settings.
  let pubKey = status_settings.getSettings().parseJSON()["result"]["public-key"].getStr
  profile.id = pubKey

  self.view.setNewProfile(profile)

  var mailservers = status_mailservers.getMailservers()
  for mailserver_config in mailservers:
    let mailserver = MailServer(name: mailserver_config[0], endpoint: mailserver_config[1])
    self.view.addMailServerToList(mailserver)

  for contact in self.status.contacts.getContacts():
    self.view.addContactToList(contact)

method onSignal(self: ProfileController, data: Signal) =
  let msgData = MessageSignal(data);
  if msgData.contacts.len > 0:
    # TODO: view should react to model changes
    self.status.chat.updateContacts(msgData.contacts)
    self.view.updateContactList(msgData.contacts)

