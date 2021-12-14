import NimQml, sequtils

import eventemitter
import ./io_interface, ./view, ./controller
import ../item
import ../../../global/global_singleton
import ../../../../app_service/service/community/service as community_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](
    delegate: T,
    events: EventEmitter,
    communityService: community_service.Service
    ): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](
    result,
    events,
    communityService
  )
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("communitiesModule", self.viewVariant)
  self.controller.init()
  self.view.load()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*[T](self: Module[T]) =
  self.moduleLoaded = true
  self.delegate.communitiesModuleDidLoad()

method setAllCommunities*[T](self: Module[T], communities: seq[CommunityDto]) =
  for c in communities:
    let communityItem = initItem(
      c.id,
      SectionType.Community,
      c.name,
      c.description,
      c.images.thumbnail,
      icon = "",
      c.color)
    self.view.addItem(communityItem)
