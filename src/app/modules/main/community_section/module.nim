import NimQml
import io_interface, view, controller

import ../../../../app_service/service/community/service as community_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*[T](delegate: T, id: string, 
  communityService: community_service.Service): 
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, id, communityService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true
  self.delegate.communitySectionDidLoad()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  discard