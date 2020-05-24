import NimQml
import ../../models/accounts
import ../../signals/types
import eventemitter
import view

type OnboardingController* = ref object of SignalSubscriber
  view*: OnboardingView
  variant*: QVariant
  model*: AccountModel
  events*: EventEmitter

# proc newController*(model: AccountModel): OnboardingController =
proc newController*(events: EventEmitter): OnboardingController =
  result = OnboardingController()
  result.events = events
  # result.model = model
  result.model = newAccountModel(events)
  result.view = newOnboardingView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: OnboardingController) =
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  let accounts = self.model.generateAddresses()

  for account in accounts:
    self.view.addAddressToList(account.toAddress())
