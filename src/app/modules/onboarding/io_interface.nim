type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAppLoaded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setPin*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getPasswordStrengthScore*(self: AccessInterface, password, userName: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method validMnemonic*(self: AccessInterface, mnemonic: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonic*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method validateLocalPairingConnectionString*(self: AccessInterface, connectionString: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method inputConnectionStringForBootstrapping*(self: AccessInterface, connectionString: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method finishOnboardingFlow*(self: AccessInterface, primaryFlowInt, secondaryFlowInt: int, dataJson: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

# This way (using concepts) is used only for the modules managed by AppController
type
  DelegateInterface* = concept c
    c.onboardingDidLoad()
