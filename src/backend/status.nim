import statusgo_backend/accounts as statusgo_backend_accounts
import statusgo_backend/core as statusgo_backend_core
import statusgo_backend/settings as statusgo_backend_settings
import chat, accounts, wallet, wallet2, node, network, messages, contacts, profile, stickers, permissions, fleet, settings, mailservers, tokens, provider
import ../eventemitter
import bitops, stew/byteutils, chronicles
import ./types/[setting]
import ./keycard

import ../backends/backend

export chat, accounts, node, messages, contacts, profile, network, permissions, eventemitter

type Status* = ref object
  backend*: Backend
  events*: EventEmitter
  chat*: ChatModel
  messages*: MessagesModel
  accounts*: AccountModel
  wallet*: WalletModel
  wallet2*: Wallet2Model
  node*: NodeModel
  profile*: ProfileModel
  contacts*: ContactModel
  network*: NetworkModel
  stickers*: StickersModel
  permissions*: PermissionsModel
  settings*: SettingsModel
  tokens*: TokensModel
  provider*: ProviderModel
  keycard*: KeycardModel

proc newStatusInstance*(backendName: string): Status =
  result = Status()
  result.backend = newBackend(backendName)
  result.events = createEventEmitter()
  result.chat = chat.newChatModel(result.events)
  result.accounts = accounts.newAccountModel(result.events)
  result.wallet = wallet.newWalletModel(result.events)
  result.wallet.initEvents()
  result.wallet2 = wallet2.newWallet2Model(result.events)
  result.node = node.newNodeModel()
  result.messages = messages.newMessagesModel(result.events)
  result.profile = profile.newProfileModel()
  result.contacts = contacts.newContactModel(result.events)
  result.network = network.newNetworkModel(result.events)
  result.stickers = stickers.newStickersModel(result.events)
  result.permissions = permissions.newPermissionsModel(result.events)
  result.settings = settings.newSettingsModel(result.events)
  result.tokens = tokens.newTokensModel(result.events)
  result.provider = provider.newProviderModel(result.events, result.permissions, result.wallet)
  result.keycard = newKeycardModel(result.backend)

proc initNode*(self: Status, statusGoDir, keystoreDir: string) =
  statusgo_backend_accounts.initNode(statusGoDir, keystoreDir)

proc startMessenger*(self: Status) {.exportc, dynlib.} =
  statusgo_backend_core.startMessenger()

proc reset*(self: Status) {.exportc, dynlib.} =
  # TODO: remove this once accounts are not tracked in the AccountsModel
  self.accounts.reset()

  # NOT NEEDED self.chat.reset()
  # NOT NEEDED self.wallet.reset()
  # NOT NEEDED self.node.reset()
  # NOT NEEDED self.profile.reset()

  # TODO: add all resets here

proc getNodeVersion*(self: Status): string  {.exportc, dynlib.} =
  statusgo_backend_settings.getWeb3ClientVersion()

# TODO: duplicated??
proc saveSetting*(self: Status, setting: Setting, value: string | bool) =
  discard statusgo_backend_settings.saveSetting(setting, value)

proc getBloomFilter*(self: Status): string {.exportc, dynlib.} =
  result = statusgo_backend_core.getBloomFilter()

proc getBloomFilterBitsSet*(self: Status): int {.exportc, dynlib.} =
  let bloomFilter = statusgo_backend_core.getBloomFilter()
  var bitCount = 0;
  for b in hexToSeqByte(bloomFilter):
    bitCount += countSetBits(b)
  return bitCount

# C Helpers
# ==============================================================================
# This creates extra functions with a simpler API for C interop. This is to avoid
# having to manually create nim strings, (we can use cstring) instead, and also
# because functions that accept more than one type for the same parameter are not
# exported correctly


proc newStatusInstance*(): Status {.exportc, dynlib.} =
  newStatusInstance("statusgo")

proc initNode*(self: Status, statusGoDir, keystoreDir: cstring) {.exportc, dynlib.} =
  self.initNode($statusGoDir, $keystoreDir)

proc saveStringSetting*(self: Status, setting: Setting, value: cstring) {.exportc, dynlib.} =
  self.saveSetting(setting, $value)

proc saveBoolSetting*(self: Status, setting: Setting, value: bool) {.exportc, dynlib.} =
  self.saveSetting(setting, value)
