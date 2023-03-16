import ../../../../../app_service/service/wallet_account/service as wallet_account_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method syncKeycard*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method generateNewAccount*(self: AccessInterface, password: string, accountName: string, color: string, emoji: string, path: string, derivedFrom: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addNewWalletAccountGeneratedFromKeycard*(self: AccessInterface, accountType: string, accountName: string, 
  color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromPrivateKey*(self: AccessInterface, privateKey: string, password: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromSeed*(self: AccessInterface, seedPhrase: string, password: string, accountName: string, color: string, emoji: string, path: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addWatchOnlyAccount*(self: AccessInterface, address: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteAccount*(self: AccessInterface, keyUid: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshWalletAccounts*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDerivedAddress*(self: AccessInterface, password: string, derivedFrom: string, path: string, hashPassword: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDerivedAddressList*(self: AccessInterface, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int, hashPassword: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDerivedAddressListForMnemonic*(self: AccessInterface, mnemonic: string, path: string, pageSize: int, pageNumber: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDerivedAddressForPrivateKey*(self: AccessInterface, privateKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method validSeedPhrase*(self: AccessInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateUser*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateUserAndDeriveAddressOnKeycardForPath*(self: AccessInterface, keyUid: string, derivationPath: string, searchForFirstAvailableAddress: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method createSharedKeycardModule*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method destroySharedKeycarModule*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticatedAndWalletAddressGenerated*(self: AccessInterface, address: string, publicKey: string, 
  derivedFrom: string, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addressDetailsFetched*(self: AccessInterface, derivedAddress: DerivedAddressDto, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSharedKeycarModuleFlowTerminated*(self: AccessInterface, lastStepInTheCurrentFlow: bool) {.base.} =
  raise newException(ValueError, "No implementation available")
