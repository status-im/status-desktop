import Tables

import controller_interface

import ../../../../app_service/service/profile/service as profile_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/language/service as language_service
import ../../../../app_service/service/mnemonic/service as mnemonic_service
import ../../../../app_service/service/privacy/service as privacy_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = 
    ref object of controller_interface.AccessInterface
    delegate: T
    profileService: profile_service.ServiceInterface
    settingsService: settings_service.ServiceInterface
    accountsService: accounts_service.ServiceInterface
    languageService: language_service.ServiceInterface
    mnemonicService: mnemonic_service.ServiceInterface
    privacyService: privacy_service.ServiceInterface

proc newController*[T](delegate: T, accountsService: accounts_service.ServiceInterface, 
  settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface, 
  languageService: language_service.ServiceInterface, mnemonicService: mnemonic_service.ServiceInterface, 
  privacyService: privacy_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.profileService = profileService
  result.settingsService = settingsService
  result.accountsService = accountsService
  result.languageService = languageService
  result.mnemonicService = mnemonicService
  result.privacyService = privacyService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method enableDeveloperFeatures*[T](self: Controller[T]) = 
  self.settingsService.enableDeveloperFeatures()

method toggleTelemetry*[T](self: Controller[T]) = 
  var value = ""
  if(not self.isTelemetryEnabled()):
    value = DEFAULT_TELEMETRY_SERVER_URL

  discard self.settingsService.saveTelemetryServerUrl(value)

method isTelemetryEnabled*[T](self: Controller[T]): bool = 
  return self.settingsService.getTelemetryServerUrl().len > 0

method toggleAutoMessage*[T](self: Controller[T]) = 
  self.settingsService.toggleAutoMessage()

method isAutoMessageEnabled*[T](self: Controller[T]): bool = 
  return self.settingsService.isAutoMessageEnabled()

method toggleDebug*[T](self: Controller[T]) = 
  discard
  # Need to sort out this
  #self.settingsService.toggleDebug()

method isDebugEnabled*[T](self: Controller[T]): bool = 
  return true
  # Need to sort out this
  #return self.settingsService.isDebugEnabled()
