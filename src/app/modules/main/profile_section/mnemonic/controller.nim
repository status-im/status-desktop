import ./controller_interface
import ../../../../../app_service/service/mnemonic/service as mnemonic_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    mnemonicService: mnemonic_service.ServiceInterface

proc newController*[T](delegate: T, mnemonicService: mnemonic_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.mnemonicService = mnemonicService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method isBackedUp*[T](self: Controller[T]): bool =
  return self.mnemonicService.isBackedUp()

method getMnemonic*[T](self: Controller[T]): string =
  return self.mnemonicService.getMnemonic()

method remove*[T](self: Controller[T]) =
  self.mnemonicService.remove()

method getWord*[T](self: Controller[T], index: int): string =
  return self.mnemonicService.getWord(index)
