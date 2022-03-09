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
import ../../../../app_service/service/visual_identity/service as visual_identity_service

export io_interface

type
  ImportCommunityState {.pure.} = enum
    Imported = 0
    ImportingInProgress
    ImportingError

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
    contactsService: contacts_service.Service,
    visualIdentityService: visual_identity_service.Service
    ): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    communityService,
    contactsService,
    visualIdentityService
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
        let contactDetails = self.controller.getContactDetails(member.id)
        result = user_item.initItem(
          member.id,
          contactDetails.displayName,
          contactDetails.details.name,
          contactDetails.details.localNickname,
          contactDetails.details.alias,
          OnlineStatus.Offline, # TODO get the actual status?
          contactDetails.icon,
          contactDetails.details.identicon,
          contactDetails.isidenticon,
          self.controller.getEmojiHash(member.id),
          self.controller.getColorHash(member.id),
          contactDetails.details.added,
          ))
    )

method setAllCommunities*(self: Module, communities: seq[CommunityDto]) =
  for community in communities:
    self.view.addItem(self.getCommunityItem(community))

method communityAdded*(self: Module, community: CommunityDto) =
  self.view.addItem(self.getCommunityItem(community))

method joinCommunity*(self: Module, communityId: string): string =
  self.controller.joinCommunity(communityId)

method communityEdited*(self: Module, community: CommunityDto) =
  self.view.model().editItem(self.getCommunityItem(community))
  self.view.communityChanged(community.id)

method requestAdded*(self: Module) =
  # TODO to model or view
  discard

method communityLeft*(self: Module, communityId: string) =
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

method banUserFromCommunity*(self: Module, pubKey: string, communityId: string) =
  self.controller.banUserFromCommunity(communityId, pubkey)

method requestToJoinCommunity*(self: Module, communityId: string, ensName: string) =
  self.controller.requestToJoinCommunity(communityId, ensName)

method requestCommunityInfo*(self: Module, communityId: string) =
  self.controller.requestCommunityInfo(communityId)

method isUserMemberOfCommunity*(self: Module, communityId: string): bool =
  self.controller.isUserMemberOfCommunity(communityId)

method userCanJoin*(self: Module, communityId: string): bool =
  self.controller.userCanJoin(communityId)

method isCommunityRequestPending*(self: Module, communityId: string): bool =
  self.controller.isCommunityRequestPending(communityId)

method deleteCommunityChat*(self: Module, communityId: string, channelId: string) =
  self.controller.deleteCommunityChat(communityId, channelId)

method communityImported*(self: Module, community: CommunityDto) =
  self.view.addItem(self.getCommunityItem(community))
  self.view.emitImportingCommunityStateChangedSignal(ImportCommunityState.Imported.int, "")

method importCommunity*(self: Module, communityKey: string) =
  self.view.emitImportingCommunityStateChangedSignal(ImportCommunityState.ImportingInProgress.int, "")
  self.controller.importCommunity(communityKey)

method onImportCommunityErrorOccured*(self: Module, error: string) =
  self.view.emitImportingCommunityStateChangedSignal(ImportCommunityState.ImportingError.int, error)
