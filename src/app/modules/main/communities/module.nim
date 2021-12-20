import NimQml, sequtils

import eventemitter
import ./io_interface as delegate_interface
import ./view, ./controller
import ../../shared_models/section_item
import ../../../global/global_singleton
import ../../../../app_service/service/community/service as community_service
import ../../../utils/image_utils
export io_interface

type 
  Module*  = ref object of io_interface.Module
    delegate: delegate_interface.Module
    controller: controller.Module
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(
    delegate: delegate_interface.Module,
    events: EventEmitter,
    communityService: community_service.Service
    ): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    communityService
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("communitiesModule", self.viewVariant)
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.communitiesModuleDidLoad()

method setAllCommunities*(self: Module, communities: seq[CommunityDto]) =
  for c in communities:
    let communityItem = initItem(
      c.id,
      SectionType.Community,
      c.name,
      c.description,
      c.images.thumbnail,
      icon = "",
      c.color,
      hasNotification = false, 
      notificationsCount = 0,
      active = false,
      enabled = true,
      c.joined,
      c.canJoin,
      c.canRequestAccess,
      c.isMember,
      c.permissions.access,
      c.permissions.ensOnly)
    self.view.addItem(communityItem)

method joinCommunity*(self: Module, communityId: string): string =
  self.controller.joinCommunity(communityId)

method requestAdded*(self: Module) =
   # TODO to model or view
method communityLeft*(self: Module, communityId: string) =
   # TODO to model or view
method communityChannelCreated*(self: Module) =
   # TODO to model or view
method communityChannelEdited*(self: Module) =
   # TODO to model or view
method communityChannelReordered*(self: Module) =
   # TODO to model or view
method communityChannelDeleted*(self: Module, communityId: string, chatId: string) =
   # TODO to model or view
method communityCategoryCreated*(self: Module) =
   # TODO to model or view
method communityCategoryEdited*(self: Module) =
   # TODO to model or view
method communityCategoryDeleted*(self: Module) =
   # TODO to model or view

method createCommunity*(self: Module, name: string, description: string, 
                        access: int, ensOnly: bool, color: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int) =
  self.controller.createCommunity(name, description, access, ensOnly, color, imagePath, aX, aY, bX, bY)


method editCommunity*(self: Module, id: string, name: string, description: string, access: int, ensOnly: bool, color: string, imagePath: string, aX: int, aY: int, bX: int, bY: int) =
  self.controller.editCommunity(id, name, description, access, ensOnly, color, imagePath, aX, aY, bX, bY )
  
method createCommunityCategory*(self: Module, communityId: string, name: string, channels: string) =
  self.controller.createCommunityCategory(communityId, name, channels)

method editCommunityCategory*(self: Module, communityId: string, categoryId: string, name: string, channels: string) =
  self.controller.editCommunityCategory(communityId, categoryid, name, channels) 

method deleteCommunityCategory*(self: Module, communityId: string, categoryId: string) =
  self.controller.deleteCommunityCategory(communityId, categoryId) 

method reorderCommunityCategories*(self: Module, communityId: string, categoryId: string, position: int) {.base} =
  self.controller.reorderCommunityCategories(communityId, categoryId, position) 
  
method reorderCommunityChannel*(self: Module, communityId: string, categoryId: string, chatId: string, position: int) {.base} =
  self.controller.reorderCommunityChannel(communityId, categoryId, chatId, position)

method leaveCommunity*(self: Module, communityId: string) =
  self.controller.leaveCommunity(communityId) 

method inviteUsersToCommunityById*(self: Module, communityId: string, pubKeysJSON: string) =
  self.controller.inviteUsersToCommunityById(communityId, pubKeysJSON)
  
method removeUserFromCommunity*(self: Module, pubKey: string) =
  self.controller.removeUserFromCommunity(communityId, pubKey)

method banUserFromCommunity*(self: Module, pubKey: string, communityId: string) =
  self.controller.banUserFromCommunity(communityId, pubkey)

method requestToJoinCommunity*(self: Module, communityId: string, ensName: string) =
  self.controller.requestToJoinCommunity(communityId, ensName)
   
method acceptRequestToJoinCommunity*(self: Module, communityId: string, requestId: string) =
  self.controller.acceptRequestToJoinCommunity(communityId, requestId)

method declineRequestToJoinCommunity*(self: Module, requestId: string) =
  self.controller.declineRequestToJoinCommunity(communityId, requestId)

method requestCommunityInfo*(self: Module, communityId: string) =
  self.controller.requestCommunityInfo(communityId)

method deleteCommunityChat*(self: Module, communityId: string, channelId: string) =
  self.controller.deleteCommunityChat(communityId, channelId)

method setCommunityMuted*(self: Module, communityId: string, muted: bool) =
  self.controller.setCommunityMuted(communityId, muted)  

method importCommunity*(self: Module, communityKey: string) =
  self.controller.importCommunity(communityKey)

method exportCommunity*(self: Module, communityId: string) =
  self.controller.exportCommunity(communityId)

method setCommunityMuted*(self: Module, communityId: string, muted: bool) =
  self.controller.setCommunityMuted(communityId, muted)