import ./controller_interface
import io_interface
import ../../../../../app_service/service/mnemonic/service as mnemonic_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    mnemonicService: mnemonic_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, mnemonicService: mnemonic_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.mnemonicService = mnemonicService

method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method isBackedUp*(self: Controller): bool =
  return self.mnemonicService.isBackedUp()

method getMnemonic*(self: Controller): string =
  return self.mnemonicService.getMnemonic()

method remove*(self: Controller) =
  self.mnemonicService.remove()

method getWord*(self: Controller, index: int): string =
  return self.mnemonicService.getWord(index)
