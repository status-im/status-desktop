import NimQml
import ../../status/libstatus/types as status_types
import ../../status/libstatus/accounts as status_accounts
import ../../status/accounts as AccountModel
import eventemitter
import view
import chronicles
import ../../signals/types
import std/wrapnils
import ../../status/status

type OnboardingController* = ref object of SignalSubscriber
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

proc init*(self: OnboardingController) =
  let accounts = self.status.accounts.generateAddresses()
  for account in accounts:
    self.view.addAccountToList(account)

proc reset*(self: OnboardingController) =
  self.view.removeAccounts()

proc handleNodeLogin(self: OnboardingController, data: Signal) =
  let response = NodeSignal(data)
  if self.view.currentAccount.account != nil:
    self.view.setLastLoginResponse(response.event)
    if ?.response.event.error == "":
      self.status.events.emit("login", AccountArgs(account: self.view.currentAccount.account.toAccount))

method onSignal(self: OnboardingController, data: Signal) =
  case data.signalType: 
  of SignalType.NodeLogin: handleNodeLogin(self, data)
  else:
    discard
