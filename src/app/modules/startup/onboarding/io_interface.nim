import NimQml
import ../../../../app_service/service/accounts/service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setupAccountError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method importAccountError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method importAccountSuccess*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedAccountByIndex*(self: AccessInterface, index: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method storeSelectedAccountAndLogin*(self: AccessInterface, password: string)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method getImportedAccount*(self: AccessInterface): GeneratedAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method validateMnemonic*(self: AccessInterface, mnemonic: string):
  string {.base.} =
  raise newException(ValueError, "No implementation available")

method importMnemonic*(self: AccessInterface, mnemonic: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayName*(self: AccessInterface, displayName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getPasswordStrengthScore*(self: AccessInterface, password: string, userName: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method generateImage*(self: AccessInterface, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")