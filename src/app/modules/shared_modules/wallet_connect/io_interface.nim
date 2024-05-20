import NimQml

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method addWalletConnectSession*(self: AccessInterface, session_json: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

type
  DelegateInterface* = concept c
