import NimQml, json, sequtils, sugar

import ./io_interface
import ../io_interface as delegate_interface
import ./view, ./controller
import ../../shared_models/section_item
import ../../shared_models/[user_item, user_model, section_model]
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/contacts/service as contacts_service

export io_interface

type 
  Module*  = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

# Forward declaration
method setAllCommunities*(self: Module, communities: seq[CommunityDto])

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service,
    contactsService: contacts_service.Service
    ): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    communityService,
    contactsService
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("communitiesModule", self.viewVariant)
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true

  self.setAllCommunities(self.controller.getAllCommunities())

  self.delegate.communitiesModuleDidLoad()

method getCommunityItem(self: Module, c: CommunityDto): SectionItem =
  return initItem(
      c.id,
      SectionType.Community,
      c.name,
      c.admin,
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
      c.canManageUsers,
      c.canRequestAccess,
      c.isMember,
      c.permissions.access,
      c.permissions.ensOnly,
      c.members.map(proc(member: Member): user_item.Item =
        let (name, image, isIdenticon) = self.controller.getContactNameAndImage(member.id)
        result = user_item.initItem(member.id, name, OnlineStatus.Offline, image, isIdenticon))
    )

method setAllCommunities*(self: Module, communities: seq[CommunityDto]) =
  for community in communities:
    self.view.addItem(self.getCommunityItem(community))

method addCommunity*(self: Module, community: CommunityDto) =
  self.view.addItem(self.getCommunityItem(community))

method joinCommunity*(self: Module, communityId: string): string =
  self.controller.joinCommunity(communityId)

method communityEdited*(self: Module, community: CommunityDto) =
  self.view.model().editItem(self.getCommunityItem(community))

method requestAdded*(self: Module) =
  # TODO to model or view
  discard

method communityLeft*(self: Module, communityId: string) =
   # TODO to model or view
  discard
  
method communityChannelCreated*(self: Module) =
   # TODO to model or view
  discard
  
method communityChannelEdited*(self: Module) =
   # TODO to model or view
  discard
  
method communityChannelReordered*(self: Module) =
   # TODO to model or view
  discard
  
method communityChannelDeleted*(self: Module, communityId: string, chatId: string) =
   # TODO to model or view
  discard
  
method communityCategoryCreated*(self: Module) =
   # TODO to model or view
  discard
  
method communityCategoryEdited*(self: Module) =
   # TODO to model or view
  discard
  
method communityCategoryDeleted*(self: Module) =
   # TODO to model or view
  discard

method createCommunity*(self: Module, name: string, description: string, 
                        access: int, ensOnly: bool, color: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int) =
  self.controller.createCommunity(name, description, access, ensOnly, color, imagePath, aX, aY, bX, bY)

method deleteCommunityCategory*(self: Module, communityId: string, categoryId: string) =
  self.controller.deleteCommunityCategory(communityId, categoryId) 

method reorderCommunityCategories*(self: Module, communityId: string, categoryId: string, position: int) =
#   self.controller.reorderCommunityCategories(communityId, categoryId, position) 
  discard
  
method removeUserFromCommunity*(self: Module, communityId: string, categoryId: string, chatId: string, position: int) =
  # self.controller.reorderCommunityChannel(communityId, categoryId, chatId, position)
  discard

method removeUserFromCommunity*(self: Module, communityId: string, pubKey: string) =
  self.controller.removeUserFromCommunity(communityId, pubKey)

method banUserFromCommunity*(self: Module, pubKey: string, communityId: string) =
  self.controller.banUserFromCommunity(communityId, pubkey)

method requestToJoinCommunity*(self: Module, communityId: string, ensName: string) =
  self.controller.requestToJoinCommunity(communityId, ensName)

method requestCommunityInfo*(self: Module, communityId: string) =
  self.controller.requestCommunityInfo(communityId)

method deleteCommunityChat*(self: Module, communityId: string, channelId: string) =
  self.controller.deleteCommunityChat(communityId, channelId)

method importCommunity*(self: Module, communityKey: string) =
  self.controller.importCommunity(communityKey)
