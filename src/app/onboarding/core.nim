import NimQml
import json
import ../../status/accounts as status_accounts
import nimcrypto
import ../../status/utils
import ../../status/libstatus
import ../../models/accounts as Models
import ../../constants/constants
import ../../status/test as status_test
import ../signals/types
import uuids
import eventemitter
import view

type OnboardingController* = ref object of SignalSubscriber
  view*: OnboardingView
  variant*: QVariant
  model*: AccountModel

proc newController*(events: EventEmitter): OnboardingController =
  result = OnboardingController()
  # TODO: events should be specific to the model itself
  result.model = newAccountModel(events)
  result.view = newOnboardingView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: OnboardingController) =
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  let accounts = self.model.generateAddresses()

  for account in accounts:
    self.view.addAddressToList(account.username, account.identicon, account.key)
