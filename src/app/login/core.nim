import NimQml, chronicles, options, std/wrapnils
import ../../status/libstatus/types as status_types
import ../../status/signals/types
import ../../status/status
import view
import ../../status/accounts as status_accounts
import ../../eventemitter
import nim_status/lib
import nim_status
import ../../status/libstatus/accounts/constants


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

proc handleNodeLogin(self: LoginController, response: NodeSignal) =
  if not self.view.isCurrentFlow: return
  if self.view.currentAccount.account != nil:
    self.view.setLastLoginResponse(response.event)
    if ?.response.event.error == "":
      self.status.events.emit("login", AccountArgs(account: self.view.currentAccount.account.toAccount))

proc init*(self: LoginController) =
  # NOTE: calling status-go openAccounts here because openAccounts sets the root datadir
  discard nim_status.openAccounts(DATADIR)

  let nodeAccounts = self.status.nimStatus.openAccounts()
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
  