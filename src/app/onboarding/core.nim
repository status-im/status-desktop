import NimQml
# import "../../status/core" as status
import ../signals/types
import eventemitter
import onboarding

type OnboardingController* = ref object of SignalSubscriber
  view*: OnboardingView
  variant*: QVariant

proc newController*(events: EventEmitter): OnboardingController =
  result = OnboardingController()
  result.view = newOnboardingView(events)
  result.variant = newQVariant(result.view)

proc delete*(self: OnboardingController) =
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  discard

# method onSignal(self: OnboardingController, data: Signal) =
#   echo "new signal received"
#   var msg = cast[WalletSignal](data)
#   self.view.setLastMessage(msg.content)
