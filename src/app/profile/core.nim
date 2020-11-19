import NimQml, json, strutils, sugar, sequtils, tables
import json_serialization
import ../../status/libstatus/mailservers as status_mailservers
import ../../status/signals/types
import ../../status/libstatus/accounts/constants
import ../../status/libstatus/types as status_types
import ../../status/libstatus/settings as status_settings
import ../../status/profile/[profile, mailserver]
import ../../status/[status, contacts]
import ../../status/chat as status_chat
import ../../status/devices
import ../../status/chat/chat
import ../../status/wallet
import ../../eventemitter
import view
import views/ens_manager
import ../chat/views/channels_list
import chronicles

type ProfileController* = ref object
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

  for name, endpoint in self.status.fleet.config.getMailservers(status_settings.getFleet()).pairs():
    let mailserver = MailServer(name: name, endpoint: endpoint)
    self.view.addMailServerToList(mailserver)

  let contacts = self.status.contacts.getContacts()
  self.status.chat.updateContacts(contacts)
  self.view.setContactList(contacts)

  self.status.events.on("channelLoaded") do(e: Args):
    var channel = ChannelArgs(e)
    if channel.chat.muted:
      if channel.chat.chatType.isOneToOne:
        discard self.view.mutedContacts.addChatItemToList(channel.chat)
        return
      discard self.view.mutedChats.addChatItemToList(channel.chat)

  self.status.events.on("channelJoined") do(e: Args):
    var channel = ChannelArgs(e)
    if channel.chat.muted:
      if channel.chat.chatType.isOneToOne:
        discard self.view.mutedContacts.addChatItemToList(channel.chat)
        return
      discard self.view.mutedChats.addChatItemToList(channel.chat)

  self.status.events.on("chatsLoaded") do(e:Args):
    self.view.mutedChatsListChanged()
    self.view.mutedContactsListChanged()

  self.status.events.on("chatUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.updateChats(evArgs.chats)

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

  self.status.events.on(SignalType.Message.event) do(e: Args):
    let msgData = MessageSignal(e);
    if msgData.contacts.len > 0:
      # TODO: view should react to model changes
      self.status.chat.updateContacts(msgData.contacts)
      self.view.updateContactList(msgData.contacts)
    if msgData.installations.len > 0:
      self.view.addDevices(msgData.installations)

  self.status.events.on(PendingTransactionType.RegisterENS.confirmed) do(e: Args):
    let tx = TransactionMinedArgs(e)
    if tx.success:
      self.view.ens.confirm(PendingTransactionType.RegisterENS, tx.data, tx.transactionHash)
    else:
      self.view.ens.revert(PendingTransactionType.RegisterENS, tx.data, tx.transactionHash, tx.revertReason)

  self.status.events.on(PendingTransactionType.SetPubKey.confirmed) do(e: Args):
    let tx = TransactionMinedArgs(e)
    if tx.success:
      self.view.ens.confirm(PendingTransactionType.SetPubKey, tx.data, tx.transactionHash)
    else:
      self.view.ens.revert(PendingTransactionType.SetPubKey, tx.data, tx.transactionHash, tx.revertReason)
