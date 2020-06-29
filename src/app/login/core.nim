import NimQml, eventemitter, chronicles, options, std/wrapnils
import ../../status/libstatus/types as status_types
import ../../signals/types
import ../../status/status
import view
import ../../status/accounts as status_accounts

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
  self.variant.delete
  self.view.delete

proc init*(self: LoginController) =
  let nodeAccounts = self.status.accounts.openAccounts()
  self.status.accounts.nodeAccounts = nodeAccounts
  for nodeAccount in nodeAccounts:
    self.view.addAccountToList(nodeAccount)

proc reset*(self: LoginController) =
  self.view.removeAccounts()

proc handleNodeStopped(self: LoginController, data: Signal) =
  self.status.events.emit("nodeStopped", Args())
  self.view.onLoggedOut()

proc handleNodeLogin(self: LoginController, data: Signal) =
  if not self.view.isCurrentFlow: return
  let response = NodeSignal(data)
  if self.view.currentAccount.account != nil:
    self.view.setLastLoginResponse(response.event)
    if ?.response.event.error == "":
      self.status.events.emit("login", AccountArgs(account: self.view.currentAccount.account.toAccount))

proc handleNodeReady(self: LoginController, data: Signal) =
  self.status.events.emit("nodeReady", Args())

method onSignal(self: LoginController, data: Signal) =
  case data.signalType: 
  of SignalType.NodeLogin: handleNodeLogin(self, data)
  of SignalType.NodeStopped: handleNodeStopped(self, data)
  of SignalType.NodeReady: handleNodeReady(self, data)
  else:
    discard
