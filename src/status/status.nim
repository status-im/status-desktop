import eventemitter

import libstatus/types
import libstatus/accounts as libstatus_accounts
import libstatus/core as libstatus_core

import chat as chat
import accounts as accounts
import wallet as wallet
import node as node
import mailservers as mailservers

type Status* = ref object
  events*: EventEmitter
  chat*: ChatModel
  mailservers*: MailserverModel
  accounts*: AccountModel
  wallet*: WalletModel
  node*: NodeModel

proc newStatusInstance*(): Status =
  result = Status()
  result.events = createEventEmitter()
  result.chat = chat.newChatModel(result.events)
  result.accounts = accounts.newAccountModel()
  result.wallet = wallet.newWalletModel()
  result.node = node.newNodeModel()
  result.mailservers = mailservers.newMailserverModel(result.events)

proc initNodeAccounts*(self: Status): seq[NodeAccount] = 
  libstatus_accounts.initNodeAccounts()

proc startMessenger*(self: Status) =
  libstatus_core.startMessenger()
