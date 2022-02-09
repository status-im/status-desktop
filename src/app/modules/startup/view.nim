import NimQml
import io_interface

type
  AppState* {.pure.} = enum
    OnboardingState = 0
    LoginState
    MainAppState

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      appState: AppState

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.appState = AppState.OnboardingState

  proc load*(self: View) =
    # In some point, here, we will setup some exposed main module related things.
    self.delegate.viewDidLoad()

  proc startUpUIRaised*(self: View) {.signal.}
  proc appStateChanged*(self: View, state: int) {.signal.}

  proc getAppState(self: View): int {.slot.} =
    return self.appState.int

  proc setAppState*(self: View, state: AppState) =
    if(self.appState == state):
      return

    self.appState = state
    self.appStateChanged(self.appState.int)

  QtProperty[int] appState:
    read = getAppState
    notify = appStateChanged

  proc logOut*(self: View) {.signal.}

  proc emitLogOut*(self: View) =
    self.logOut()
