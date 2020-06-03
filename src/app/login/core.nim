import NimQml, eventemitter, chronicles, options, std/wrapnils
import ../../status/libstatus/types as status_types
import ../../signals/types
import ../../status/status
import view

type LoginController* = ref object of SignalSubscriber
  status*: Status
  view*: LoginView
  variant*: QVariant

proc newController*(status: Status): LoginController =
  result = LoginController()
  result.status = status
  result.view = newLoginView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: LoginController) =
  delete self.view
  delete self.variant

proc init*(self: LoginController, nodeAccounts: seq[NodeAccount]) =
  self.status.accounts.nodeAccounts = nodeAccounts
  for nodeAccount in nodeAccounts:
    self.view.addAccountToList(nodeAccount)

proc handleNodeLogin(self: LoginController, data: Signal) =
  let response = NodeSignal(data)
  if self.view.currentAccount.account != nil:
    self.view.setLastLoginResponse(response.event)
    if ?.response.event.error == "":
      self.status.events.emit("login", AccountArgs(account: self.view.currentAccount.account.toAccount))

method onSignal(self: LoginController, data: Signal) =
  if data.signalType == SignalType.NodeLogin:
    self.handleNodeLogin(data)
  else:
    discard
