import NimQml
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      startWithOnboardingScreen: bool
      
  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.startWithOnboardingScreen = true

  proc load*(self: View) =
    # In some point, here, we will setup some exposed main module related things.
    self.delegate.viewDidLoad()

  proc startWithOnboardingScreenChanged*(self: View) {.signal.}

  proc getStartWithOnboardingScreen(self: View): bool {.slot.} =
    return self.startWithOnboardingScreen

  proc setStartWithOnboardingScreen*(self: View, value: bool) {.slot.} =
    if(self.startWithOnboardingScreen == value):
      return

    self.startWithOnboardingScreen = value
    self.startWithOnboardingScreenChanged()

  QtProperty[bool] startWithOnboardingScreen:
    read = getStartWithOnboardingScreen
    notify = startWithOnboardingScreenChanged