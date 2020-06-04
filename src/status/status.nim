import eventemitter

import libstatus/types
import libstatus/accounts as libstatus_accounts
import libstatus/core as libstatus_core

import chat as chat
import accounts as accounts
import wallet as wallet
import node as node
import mailservers as mailservers
import profile
import ../signals/types as signal_types

type Status* = ref object
  events*: EventEmitter
  chat*: ChatModel
  mailservers*: MailserverModel
  accounts*: AccountModel
  wallet*: WalletModel
  node*: NodeModel
  profile*: ProfileModel

proc newStatusInstance*(): Status =
  result = Status()
  result.events = createEventEmitter()
  result.chat = chat.newChatModel(result.events)
  result.accounts = accounts.newAccountModel(result.events)
  result.wallet = wallet.newWalletModel(result.events)
  result.wallet.initEvents()
  result.node = node.newNodeModel()
  result.mailservers = mailservers.newMailserverModel(result.events)
  result.profile = profile.newProfileModel()

proc initNode*(self: Status) = 
  libstatus_accounts.initNode()

proc startMessenger*(self: Status) =
  libstatus_core.startMessenger()

proc reset*(self: Status) =
  # TODO: remove this once accounts are not tracked in the AccountsModel
  self.accounts.reset()
  
  # NOT NEEDED self.chat.reset()
  # NOT NEEDED self.wallet.reset()
  # NOT NEEDED self.node.reset()
  # NOT NEEDED self.mailservers.reset()
  # NOT NEEDED self.profile.reset()

  # TODO: add all resets here
