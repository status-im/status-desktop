import ./controller_interface
import ../../../../../app_service/service/appearance/service as appearance_service

# import ./item as item

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    appearanceService: appearance_service.ServiceInterface

proc newController*[T](delegate: T, appearanceService: appearance_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.appearanceService = appearanceService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method readTextFile*[T](self: Controller[T], filePath: string): string =
  return self.appearanceService.readTextFile(filePath)

method writeTextFile*[T](self: Controller[T], filePath: string, text: string): void =
  discard self.appearanceService.writeTextFile(filePath, text)
