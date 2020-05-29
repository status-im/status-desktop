import NimQml
import ../../status/libstatus/types as status_types
import ../../signals/types
import eventemitter
import view
import ../../status/accounts as AccountModel
import chronicles
import options
import std/wrapnils

type LoginController* = ref object of SignalSubscriber
  view*: LoginView
  variant*: QVariant
  appEvents*: EventEmitter
  model: AccountModel

proc newController*(appEvents: EventEmitter): LoginController =
  result = LoginController()
  result.appEvents = appEvents
  result.model = newAccountModel()
  result.view = newLoginView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: LoginController) =
  delete self.view
  delete self.variant

proc init*(self: LoginController, nodeAccounts: seq[NodeAccount]) =
  self.model.nodeAccounts = nodeAccounts
  for nodeAccount in nodeAccounts:
    self.view.addAccountToList(nodeAccount)

proc handleNodeLogin(self: LoginController, data: Signal) =
  var response = NodeSignal(data)
  self.view.setLastLoginResponse($response.event.toJson)
  if ?.response.event.error == "" and self.model.currentAccount != nil:
    self.appEvents.emit("login", AccountArgs(account: self.model.currentAccount))

method onSignal(self: LoginController, data: Signal) =
  if data.signalType == SignalType.NodeLogin:
    self.handleNodeLogin(data)
  else:
    discard