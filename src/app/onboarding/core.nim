import NimQml
import ../../models/accounts as Models
# import ../../constants/constants
import ../signals/types
import eventemitter
import view

type OnboardingController* = ref object of SignalSubscriber
  view*: OnboardingView
  variant*: QVariant
  model*: AccountModel

proc newController*(model: AccountModel): OnboardingController =
  result = OnboardingController()
  result.model = model
  result.view = newOnboardingView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: OnboardingController) =
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  let accounts = self.model.generateAddresses()

  for account in accounts:
    self.view.addAddressToList(account.name, account.photoPath, account.address)
