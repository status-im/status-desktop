import chronicles, strutils
import io_interface

import app/core/eventemitter
import app_service/service/general/service as general_service
import app_service/service/accounts/service as accounts_service
import app_service/service/accounts/dto/image_crop_rectangle
import app_service/service/devices/service as devices_service
import app_service/service/keycardV2/service as keycard_serviceV2

logScope:
  topics = "onboarding-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    generalService: general_service.Service
    accountsService: accounts_service.Service
    devicesService: devices_service.Service
    keycardServiceV2: keycard_serviceV2.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    generalService: general_service.Service,
    accountsService: accounts_service.Service,
    devicesService: devices_service.Service,
    keycardServiceV2: keycard_serviceV2.Service,
  ):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.generalService = generalService
  result.accountsService = accountsService
  result.devicesService = devicesService
  result.keycardServiceV2 = keycardServiceV2

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc setPin*(self: Controller, pin: string): bool =
  self.keycardServiceV2.setPin(pin)
  discard

proc getPasswordStrengthScore*(self: Controller, password, userName: string): int =
  return self.generalService.getPasswordStrengthScore(password, userName)

proc validMnemonic*(self: Controller, mnemonic: string): bool =
  let (_, err) = self.accountsService.validateMnemonic(mnemonic)
  if err.len == 0:
    return true
  return false

proc buildSeedPhrasesFromIndexes(self: Controller, seedPhraseIndexes: seq[int]): string =
  if seedPhraseIndexes.len == 0:
    error "keycard error: cannot generate mnemonic"
    return
  let sp = self.keycardServiceV2.buildSeedPhrasesFromIndexes(seedPhraseIndexes)
  return sp.join(" ")

proc getMnemonic*(self: Controller): string =
  let indexes = self.keycardServiceV2.getMnemonicIndexes()
  return self.buildSeedPhrasesFromIndexes(indexes)

proc validateLocalPairingConnectionString*(self: Controller, connectionString: string): bool =
  let err = self.devicesService.validateConnectionString(connectionString)
  return err.len == 0

proc inputConnectionStringForBootstrapping*(self: Controller, connectionString: string) =
  self.devicesService.inputConnectionStringForBootstrapping(connectionString)

proc createAccountAndLogin*(self: Controller, password: string): string =
  return self.accountsService.createAccountAndLogin(
    password,
    displayName = "",
    imagePath = "",
    ImageCropRectangle(),
  )

proc restoreAccountAndLogin*(self: Controller, password, mnemonic: string, recoverAccount: bool, keycardInstanceUID: string): string =
  return self.accountsService.importAccountAndLogin(
    mnemonic,
    password,
    recoverAccount,
    displayName = "",
    imagePath = "",
    ImageCropRectangle(),
    keycardInstanceUID,
  )