import NimQml, chronicles, std/wrapnils
import status/accounts as AccountModel
import status/[signals, status]
import status/types/[account]
import eventemitter
import view

type OnboardingController* = ref object
  view*: OnboardingView
  variant*: QVariant
  status: Status

proc newController*(status: Status): OnboardingController =
  result = OnboardingController()
  result.status = status
  result.view = newOnboardingView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: OnboardingController) =
  delete self.variant
  delete self.view

proc reset*(self: OnboardingController) =
  self.view.removeAccounts()

proc moveToAppState*(self: OnboardingController) =
  self.view.moveToAppState()

proc handleNodeLogin(self: OnboardingController, response: NodeSignal) =
  if not self.view.isCurrentFlow: return
  if self.view.currentAccount.account != nil:
    self.view.setLastLoginResponse(response.event)
    if ?.response.event.error == "":
      self.status.events.emit("login", AccountArgs(account: self.view.currentAccount.account.toAccount))

proc init*(self: OnboardingController) =
  let accounts = self.status.accounts.generateAddresses()
  echo "--OLD-OnboardingController- accounts: "#, repr(accounts)
  for account in accounts:
    echo "--OLD-OnboardingController- accounts: ", repr(account)
    self.view.addAccountToList(account)

  self.status.events.on(SignalType.NodeLogin.event) do(e:Args):
    echo "--OLD-OnboardingController- OnNodeLoginEvent: ", repr(e)
    self.handleNodeLogin(NodeSignal(e))
  