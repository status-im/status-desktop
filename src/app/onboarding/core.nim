import NimQml
import ../../models/accounts
import ../../signals/types
import eventemitter
import view

type OnboardingController* = ref object of SignalSubscriber
  view*: OnboardingView
  variant*: QVariant
  model*: AccountModel
  appEvents*: EventEmitter

proc newController*(appEvents: EventEmitter): OnboardingController =
  result = OnboardingController()
  result.appEvents = appEvents
  result.model = newAccountModel()
  result.view = newOnboardingView(result.model)
  result.variant = newQVariant(result.view)
  result.model.events.on("accountsReady") do(a: Args):
    appEvents.emit("accountsReady", a)

proc delete*(self: OnboardingController) =
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  let accounts = self.model.generateAddresses()

  for account in accounts:
    self.view.addAddressToList(account.toAddress())
