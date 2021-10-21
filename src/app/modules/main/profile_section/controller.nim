import Tables

import controller_interface

import ../../../../app_service/service/profile/service as profile_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/language/service as language_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = 
    ref object of controller_interface.AccessInterface
    delegate: T
    profileService: profile_service.ServiceInterface
    settingsService: settings_service.ServiceInterface
    accountsService: accounts_service.ServiceInterface
    languageService: language_service.ServiceInterface

proc newController*[T](delegate: T, accountsService: accounts_service.ServiceInterface, settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface, languageService: language_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.profileService = profileService
  result.settingsService = settingsService
  result.accountsService = accountsService
  result.languageService = languageService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard
