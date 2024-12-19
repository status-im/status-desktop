import chronicles
import io_interface

import app/core/eventemitter
import app_service/service/general/service as general_service
import app_service/service/accounts/service as accounts_service
import app_service/service/devices/service as devices_service

logScope:
  topics = "onboarding-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    generalService: general_service.Service
    accountsService: accounts_service.Service
    devicesService: devices_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    generalService: general_service.Service,
    accountsService: accounts_service.Service,
    devicesService: devices_service.Service,
  ):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.generalService = generalService
  result.accountsService = accountsService
  result.devicesService = devicesService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc setPin*(self: Controller, pin: string): bool =
  # self.keycardService.setPin(pin)
  # TODO implement new keycard service
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
  # TODO implement new keycard service
  # let sp = self.keycardService.buildSeedPhrasesFromIndexes(seedPhraseIndexes)
  # return sp.join(" ")

proc getMnemonic*(self: Controller): string =
  # TODO implement new keycard service
  # let indexes = self.keycardService.getMnemonicIndexes()
  # return self.buildSeedPhrasesFromIndexes(indexes)
  discard

proc validateLocalPairingConnectionString*(self: Controller, connectionString: string): bool =
  let err = self.devicesService.validateConnectionString(connectionString)
  return err.len == 0

proc inputConnectionStringForBootstrapping*(self: Controller, connectionString: string) =
  self.devicesService.inputConnectionStringForBootstrapping(connectionString)