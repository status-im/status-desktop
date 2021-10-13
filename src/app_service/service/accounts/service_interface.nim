import ./dto/accounts as dto_accounts
import ./dto/generated_accounts as dto_generated_accounts

import status/fleet as status_lib_fleet

export dto_accounts
export dto_generated_accounts
export status_lib_fleet

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method openedAccounts*(self: ServiceInterface): 
  seq[AccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method generatedAccounts*(self: ServiceInterface): 
  seq[GeneratedAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method setupAccount*(self: ServiceInterface, fleetConfig: FleetConfig, 
  accountId, password: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getLoggedInAccount*(self: ServiceInterface): AccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getImportedAccount*(self: ServiceInterface): GeneratedAccountDto 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method isFirstTimeAccountLogin*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method validateMnemonic*(self: ServiceInterface, mnemonic: string): 
  string {.base.} =
  raise newException(ValueError, "No implementation available")

method importMnemonic*(self: ServiceInterface, mnemonic: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method login*(self: ServiceInterface, account: AccountDto, password: string): 
  string {.base.} =
  raise newException(ValueError, "No implementation available")

method clear*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method generateAlias*(self: ServiceInterface, publicKey: string): string {.base.} =
  raise newException(ValueError, "No implementation available")
