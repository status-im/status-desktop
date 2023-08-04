import Tables, NimQml

import app_service/service/wallet_account/dto/derived_address_dto

type ImportOption* {.pure.}= enum
  SeedPhrase = 1,
  PrivateKey = 2

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface, keyUid: string, importOption: ImportOption) {.base.} =
  raise newException(ValueError, "No implementation available")

method closeKeypairImportPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onBackActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onPrimaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCancelActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method changePrivateKey*(self: AccessInterface, privateKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method changeSeedPhrase*(self: AccessInterface, seedPhrase: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method validSeedPhrase*(self: AccessInterface, seedPhrase: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method onAddressDetailsFetched*(self: AccessInterface, derivedAddresses: seq[DerivedAddressDto], error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  DelegateInterface* = concept c
    c.onKeypairImportModuleLoaded()
    c.destroyKeypairImportPopup()