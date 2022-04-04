import NimQml, algorithm, json, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller, model, item

import ../../../../global/app_signals
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/contacts/service as contact_service
from ../../../../../app_service/service/community/dto/community import CommunityDto

export io_interface

logScope:
  topics = "profile-section-notifications-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  chatService: chat_service.Service,
  contactService: contact_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, chatService, contactService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc comp[T](x,y: T):int = 
  if x.joinedTimestamp > y.joinedTimestamp: return 1
  elif x.joinedTimestamp < y.joinedTimestamp: return -1
  else: return 0

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc createItem(self: Module, id, name, image, color: string, joinedTimestamp: int64, itemType: Type): Item =
  let allExemptions = singletonInstance.localAccountSensitiveSettings.getNotifSettingExemptionsAsJson()
  var item = initItem(id, name, image, color, joinedTimestamp, itemType)
  if(allExemptions.contains(id)):
    let obj = allExemptions[id]
    if(obj.contains(EXEMPTION_KEY_MUTE_ALL_MESSAGES)):
      item.muteAllMessages = obj[EXEMPTION_KEY_MUTE_ALL_MESSAGES].getBool
    if(obj.contains(EXEMPTION_KEY_PERSONAL_MENTIONS)):
      item.personalMentions = obj[EXEMPTION_KEY_PERSONAL_MENTIONS].getStr
    if(obj.contains(EXEMPTION_KEY_GLOBAL_MENTIONS)):
      item.globalMentions = obj[EXEMPTION_KEY_GLOBAL_MENTIONS].getStr
    if(obj.contains(EXEMPTION_KEY_OTHER_MESSAGES)):
      item.otherMessages = obj[EXEMPTION_KEY_OTHER_MESSAGES].getStr
  return item

proc createChatItem(self: Module, chatDto: ChatDto): Item =
  var chatName = chatDto.name
  var chatImage = chatDto.icon
  var itemType = item.Type.GroupChat
  if(chatDto.chatType == ChatType.OneToOne):
    let contactDetails = self.controller.getContactDetails(chatDto.id)
    chatName = contactDetails.displayName
    chatImage = contactDetails.icon
    itemType = item.Type.OneToOneChat

  return self.createItem(chatDto.id, chatName, chatImage, chatDto.color, chatDto.joined, itemType)

proc initModel(self: Module) =
  let channelGroups = self.controller.getChannelGroups()
  var items: seq[Item]
  for cg in channelGroups:
    if cg.channelGroupType == ChannelGroupType.Community:
      if(not singletonInstance.localAccountSensitiveSettings.getCommunitiesEnabled()):
        continue
      let item = self.createItem(cg.id, cg.name, cg.images.thumbnail, cg.color, joinedTimestamp = 0, item.Type.Community)
      items.add(item)
    elif cg.channelGroupType == ChannelGroupType.Personal:
      for c in cg.chats:
        if c.chatType != ChatType.OneToOne and c.chatType != ChatType.PrivateGroupChat:
          continue
        let item = self.createChatItem(c)
        items.add(item)

  # Sort to get most recent first
  items.sort(comp, SortOrder.Descending)
  self.view.exemptionsModel().setItems(items)

method viewDidLoad*(self: Module) =
  self.initModel()
  self.moduleLoaded = true
  self.delegate.notificationsModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method sendTestNotification*(self: Module, title: string, message: string) =
  singletonInstance.globalEvents.showTestNotification(title, message)

method saveExemptions*(self: Module, itemId: string, muteAllMessages: bool, personalMentions: string, 
  globalMentions: string, otherMessages: string) =
  var allExemptions = singletonInstance.localAccountSensitiveSettings.getNotifSettingExemptionsAsJson()
  allExemptions[itemId] = %* {
    EXEMPTION_KEY_MUTE_ALL_MESSAGES: muteAllMessages,
    EXEMPTION_KEY_PERSONAL_MENTIONS: personalMentions, 
    EXEMPTION_KEY_GLOBAL_MENTIONS: globalMentions,
    EXEMPTION_KEY_OTHER_MESSAGES: otherMessages
  }
  
  self.view.exemptionsModel().updateExemptions(itemId, muteAllMessages, personalMentions, globalMentions, otherMessages)
  
  singletonInstance.localAccountSensitiveSettings.setNotifSettingExemptions($allExemptions)

method onToggleSection*(self: Module, sectionType: SectionType) =
  if(sectionType != SectionType.Community):
    return

  if(singletonInstance.localAccountSensitiveSettings.getCommunitiesEnabled()):
    let channelGroups = self.controller.getChannelGroups()
    for cg in channelGroups:
      if cg.channelGroupType == ChannelGroupType.Community:
        let item = self.createItem(cg.id, cg.name, cg.images.thumbnail, cg.color, joinedTimestamp = 0, item.Type.Community)
        self.view.exemptionsModel().addItem(item)
  else:
    let allExemptions = singletonInstance.localAccountSensitiveSettings.getNotifSettingExemptionsAsJson()
    for item in self.view.exemptionsModel().modelIterator():
      if(allExemptions.contains(item.id)):
        allExemptions.delete(item.id)
    singletonInstance.localAccountSensitiveSettings.setNotifSettingExemptions($allExemptions)
    self.view.exemptionsModel().removeItemsByType(item.Type.Community)
  
method addCommunity*(self: Module, communityDto: CommunityDto) =
  let item = self.createItem(communityDto.id, communityDto.name, communityDto.images.thumbnail, communityDto.color, 
    joinedTimestamp = 0, item.Type.Community)
  self.view.exemptionsModel().addItem(item)

method editCommunity*(self: Module, communityDto: CommunityDto) =
  self.view.exemptionsModel().removeItemById(communityDto.id)
  let item = self.createItem(communityDto.id, communityDto.name, communityDto.images.thumbnail, communityDto.color, 
    joinedTimestamp = 0, item.Type.Community)
  self.view.exemptionsModel().addItem(item)

method removeItemWithId*(self: Module, itemId: string) =
  var allExemptions = singletonInstance.localAccountSensitiveSettings.getNotifSettingExemptionsAsJson()
  if(allExemptions.contains(itemId)):
    allExemptions.delete(itemId)
  singletonInstance.localAccountSensitiveSettings.setNotifSettingExemptions($allExemptions)
  self.view.exemptionsModel().removeItemById(itemId)
  
method addChat*(self: Module, chatDto: ChatDto) =
  let ind = self.view.exemptionsModel().findIndexForItemId(chatDto.id)
  if(ind != -1):
    return
  let item = self.createChatItem(chatDto)
  self.view.exemptionsModel().addItem(item)

method addChat*(self: Module, itemId: string) =
  let ind = self.view.exemptionsModel().findIndexForItemId(itemId)
  if(ind != -1):
    return
  let chatDto = self.controller.getChatDetails(itemId)
  self.addChat(chatDto)

method setName*(self: Module, itemId: string, name: string) =
  self.view.exemptionsModel().updateName(itemId, name)