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
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  let accounts = self.status.accounts.generateAddresses()
  for account in accounts:
    self.view.addAccountToList(account)

proc handleNodeLogin(self: OnboardingController, data: Signal) =
  var response = NodeSignal(data)
  self.view.setLastLoginResponse($response.event.toJson)
  if ?.response.event.error == "" and self.status.accounts.currentAccount != nil:
    self.status.events.emit("login", AccountArgs(account: self.status.accounts.currentAccount))

method onSignal(self: OnboardingController, data: Signal) =
  if data.signalType == SignalType.NodeLogin:
    self.handleNodeLogin(data)
  else:
    discard
