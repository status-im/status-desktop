import ../../../../app_service/service/accounts/service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getGeneratedAccounts*(self: AccessInterface): seq[GeneratedAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedAccountByIndex*(self: AccessInterface, index: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayName*(self: AccessInterface, displayName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method storeSelectedAccountAndLogin*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getImportedAccount*(self: AccessInterface): GeneratedAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method validateMnemonic*(self: AccessInterface, mnemonic: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method importMnemonic*(self: AccessInterface, mnemonic: string) {.base.} =
  raise newException(ValueError, "No implementation available")
