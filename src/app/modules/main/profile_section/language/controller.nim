import ./controller_interface
import ../../../../../app_service/service/language/service as language_service

# import ./item as item

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    languageService: language_service.ServiceInterface

proc newController*[T](delegate: T, languageService: language_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.languageService = languageService

method delete*[T](self: Controller[T]) =
  discard

method changeLanguage*[T](self: Controller[T], locale: string) =
  self.languageService.setLanguage(locale)
