import NimQml
import ../../status/libstatus/types as status_types
import ../../status/libstatus/accounts as status_accounts
import ../../status/accounts as AccountModel
import eventemitter
import view
import chronicles
import ../../signals/types
import std/wrapnils

type OnboardingController* = ref object of SignalSubscriber
  view*: OnboardingView
  variant*: QVariant
  appEvents*: EventEmitter
  model: AccountModel

proc newController*(appEvents: EventEmitter): OnboardingController =
  result = OnboardingController()
  result.appEvents = appEvents
  result.model = newAccountModel()
  result.view = newOnboardingView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: OnboardingController) =
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  let accounts = self.model.generateAddresses()
  for account in accounts:
    self.view.addAccountToList(account)

proc handleNodeLogin(self: OnboardingController, data: Signal) =
  var response = NodeSignal(data)
  self.view.setLastLoginResponse($response.event.toJson)
  if ?.response.event.error == "" and self.model.currentAccount != nil:
    self.appEvents.emit("login", AccountArgs(account: self.model.currentAccount))

method onSignal(self: OnboardingController, data: Signal) =
  if data.signalType == SignalType.NodeLogin:
    self.handleNodeLogin(data)
  else:
    discard
