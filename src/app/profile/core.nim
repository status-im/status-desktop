import NimQml, json, tables
import json_serialization
import status/[status, settings]
import status/contacts as status_contacts
import status/chat as status_chat
import status/devices as status_devices
import status/chat/chat
import status/wallet
import status/types/[account, transaction, setting, profile, mailserver]
import ../core/[main]
import ../core/tasks/marathon/mailserver/events
import eventemitter
import view
import views/[ens_manager, devices, network, mailservers, muted_chats]
import ../chat/views/channels_list
import chronicles

const DEFAULT_NETWORK_NAME* = "mainnet_rpc"

type ProfileController* = ref object
  view*: ProfileView
  variant*: QVariant
  status: Status
  statusFoundation: StatusFoundation

proc newController*(status: Status, statusFoundation: StatusFoundation,
  changeLanguage: proc(locale: string)): ProfileController =
  result = ProfileController()
  result.status = status
  result.statusFoundation = statusFoundation
  result.view = newProfileView(status, statusFoundation, changeLanguage)
  result.variant = newQVariant(result.view)

proc delete*(self: ProfileController) =
  delete self.variant
  delete self.view

proc init*(self: ProfileController, account: Account) =
  let profile = account.toProfile()

  let pubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")
  let network = self.status.settings.getSetting[:string](Setting.Networks_CurrentNetwork, DEFAULT_NETWORK_NAME)
  let appearance = self.status.settings.getSetting[:int](Setting.Appearance)
  let messagesFromContactsOnly = self.status.settings.getSetting[:bool](Setting.MessagesFromContactsOnly)
  let sendUserStatus = self.status.settings.getSetting[:bool](Setting.SendUserStatus)
  let currentUserStatus = self.status.settings.getSetting[:JsonNode](Setting.CurrentUserStatus){"statusType"}.getInt()

  profile.appearance = appearance
  profile.id = pubKey
  profile.address = account.keyUid
  profile.messagesFromContactsOnly = messagesFromContactsOnly
  profile.sendUserStatus = sendUserStatus
  profile.currentUserStatus = currentUserStatus

  let identityImage = self.status.profile.getIdentityImage(profile.address)
  if (identityImage.thumbnail != ""):
    profile.identityImage = identityImage

  self.view.devices.addDevices(status_devices.getAllDevices())
  self.view.devices.setDeviceSetup(status_devices.isDeviceSetup())
  self.view.setNewProfile(profile)
  self.view.network.setNetwork(network)
  self.view.ens.init()
  self.view.initialized()

  for name, endpoint in self.status.fleet.config.getMailservers(self.status.settings.getFleet(), self.status.settings.getWakuVersion() == 2).pairs():
    let mailserver = MailServer(name: name, endpoint: endpoint)
    self.view.mailservers.add(mailserver)

  for mailserver in self.status.settings.getMailservers().getElems():
    let mailserver = MailServer(name: mailserver["name"].getStr(), endpoint: mailserver["address"].getStr())
    self.view.mailservers.add(mailserver)

  self.status.events.on("channelLoaded") do(e: Args):
    var channel = ChannelArgs(e)
    if channel.chat.muted:
      if channel.chat.chatType.isOneToOne:
        discard self.view.mutedChats.mutedContacts.addChatItemToList(channel.chat)
        return
      discard self.view.mutedChats.mutedChats.addChatItemToList(channel.chat)

  self.status.events.on("channelJoined") do(e: Args):
    var channel = ChannelArgs(e)
    if channel.chat.muted:
      if channel.chat.chatType.isOneToOne:
        discard self.view.mutedChats.mutedContacts.addChatItemToList(channel.chat)
        return
      discard self.view.mutedChats.mutedChats.addChatItemToList(channel.chat)

  self.status.events.on("chatsLoaded") do(e:Args):
    self.view.mutedChats.mutedChatsListChanged()
    self.view.mutedChats.mutedContactsListChanged()

  self.status.events.on("chatUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.mutedChats.updateChats(evArgs.chats)

  self.status.events.on("mailserver:changed") do(e: Args):
    let mailserverArg = MailserverArgs(e)
    self.view.mailservers.activeMailserverChanged(mailserverArg.peer)

  self.status.events.on(SignalType.HistoryRequestStarted.event) do(e: Args):
    info "history request started", topics="mailserver-interaction"

  self.status.events.on(SignalType.HistoryRequestCompleted.event) do(e: Args):
    info "history request completed", topics="mailserver-interaction"

  self.status.events.on(SignalType.HistoryRequestFailed.event) do(e: Args):
    let h = HistoryRequestFailedSignal(e)
    info "history request failed", topics="mailserver-interaction", errorMessage=h.errorMessage


  self.status.events.on(SignalType.Message.event) do(e: Args):
    let msgData = MessageSignal(e);
    if msgData.installations.len > 0:
      self.view.devices.addDevices(msgData.installations)

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
