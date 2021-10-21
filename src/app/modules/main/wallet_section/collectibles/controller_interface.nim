import ../../../../../app_service/service/wallet_account/service_interface as wallet_account_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccount*(self: AccessInterface, accountIndex: int): wallet_account_service.WalletAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    