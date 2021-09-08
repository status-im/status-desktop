import NimQml, chronicles, options, std/wrapnils
import status/status
import status/types/[account, rpc_response]
import status/signals/[base]
import view
import eventemitter

type LoginController* = ref object
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

proc reset*(self: LoginController) =
  self.view.removeAccounts()

proc moveToAppState*(self: LoginController) =
  self.view.moveToAppState()

proc handleNodeLogin(self: LoginController, response: NodeSignal) =
  if not self.view.isCurrentFlow: return
  if self.view.currentAccount.account != nil:
    self.view.setLastLoginResponse(response.event)
    if ?.response.event.error == "":
      self.status.events.emit("login", AccountArgs(account: self.view.currentAccount.account.toAccount))

proc init*(self: LoginController) =
  let nodeAccounts = self.status.accounts.openAccounts()
  self.status.accounts.nodeAccounts = nodeAccounts
  for nodeAccount in nodeAccounts:
    self.view.addAccountToList(nodeAccount)

  self.status.events.on(SignalType.NodeStopped.event) do(e:Args):
    self.status.events.emit("nodeStopped", Args())
    self.view.onLoggedOut()

  self.status.events.on(SignalType.NodeReady.event) do(e:Args):
    self.status.events.emit("nodeReady", Args())

  self.status.events.on(SignalType.NodeLogin.event) do(e:Args):
    self.handleNodeLogin(NodeSignal(e))
  