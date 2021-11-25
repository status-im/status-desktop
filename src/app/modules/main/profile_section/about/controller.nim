import ./controller_interface
import ../../../../../app_service/service/about/service as about_service

# import ./item as item

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    aboutService: about_service.ServiceInterface

proc newController*[T](delegate: T, aboutService: about_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.aboutService = aboutService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getAppVersion*[T](self: Controller[T]): string =
  return self.aboutService.getAppVersion()

method getNodeVersion*[T](self: Controller[T]): string =
  return self.aboutService.getNodeVersion()
