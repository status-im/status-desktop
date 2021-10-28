import ./controller_interface
import ../../../../../app_service/service/syncnode/service as syncnode_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    syncnodeService: syncnode_service.ServiceInterface

proc newController*[T](delegate: T, syncnodeService: syncnode_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.syncnodeService = syncnodeService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getActiveMailServer*[T](self: Controller[T]): string =
  return self.syncnodeService.getActiveMailServer()

method getAutomaticSelection*[T](self: Controller[T]): bool =
  return self.syncnodeService.getAutomaticSelection()

method pinMailserver*[T](self: Controller[T], id: string) =
  self.syncnodeService.pinMailserver(id)

method enableAutomaticSelection*[T](self: Controller[T], value: bool) =
  self.syncnodeService.enableAutomaticSelection(value)

method saveMailserver*[T](self: Controller[T], name: string, address: string) =
  self.syncnodeService.saveMailserver(name, address)
