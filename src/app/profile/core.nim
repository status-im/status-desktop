import NimQml, json, eventemitter, strutils, sugar, sequtils
import json_serialization
import ../../status/libstatus/mailservers as status_mailservers
import ../../signals/types
import ../../status/libstatus/accounts/constants
import ../../status/libstatus/types as status_types
import ../../status/libstatus/settings as status_settings
import ../../status/profile/[profile, mailserver]
import ../../status/[status, contacts]
import ../../status/chat as status_chat
import ../../status/devices
import ../../status/chat/chat
import view
import views/ens_manager
import chronicles

type ProfileController* = ref object of SignalSubscriber
  view*: ProfileView
  variant*: QVariant
  status*: Status

proc newController*(status: Status, changeLanguage: proc(locale: string)): ProfileController =
  result = ProfileController()
  result.status = status
  result.view = newProfileView(status, changeLanguage)
  result.variant = newQVariant(result.view)

proc delete*(self: ProfileController) =
  delete self.variant
  delete self.view

proc init*(self: ProfileController, account: Account) =
  let profile = account.toProfileModel()

  let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
  let network = status_settings.getSetting[string](Setting.Networks_CurrentNetwork, constants.DEFAULT_NETWORK_NAME)
  let appearance = status_settings.getSetting[int](Setting.Appearance)
  profile.appearance = appearance
  profile.id = pubKey
  profile.address = account.keyUid

  self.view.addDevices(devices.getAllDevices())
  self.view.setDeviceSetup(devices.isDeviceSetup())
  self.view.setNewProfile(profile)
  self.view.setNetwork(network)
  self.view.ens.init()

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

  self.status.events.on("contactBlocked") do(e: Args):
    let contacts = self.status.contacts.getContacts()
    self.view.setContactList(contacts)

  self.status.events.on("contactUnblocked") do(e: Args):
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
  if msgData.installations.len > 0:
    self.view.addDevices(msgData.installations)
