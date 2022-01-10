import sequtils, sugar
import controller_interface
import io_interface

import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/message/service as message_service

import ../../../../../core/eventemitter

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    sectionId: string
    chatId: string
    belongsToCommunity: bool
    isUsersListAvailable: bool #users list is not available for 1:1 chat
    contactService: contact_service.Service
    communityService: community_service.Service
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string, 
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.sectionId = sectionId
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.isUsersListAvailable = isUsersListAvailable
  result.contactService = contactService
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  if(self.isUsersListAvailable):
    self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
      let args = MessagesLoadedArgs(e)
      if(self.chatId != args.chatId):
        return

      self.delegate.newMessagesLoaded(args.messages)

    self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
      var args = ContactArgs(e)
      self.delegate.contactNicknameChanged(args.contactId)

    self.events.on(SIGNAL_CONTACTS_STATUS_UPDATED) do(e: Args):
      var args = ContactsStatusUpdatedArgs(e)
      self.delegate.contactsStatusUpdated(args.statusUpdates)

    self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
      var args = ContactArgs(e)
      self.delegate.contactUpdated(args.contactId)

    self.events.on(SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED) do(e: Args):
      self.delegate.loggedInUserImageChanged()

method getMembersPublicKeys*(self: Controller): seq[string] = 
  # in case of 1:1 chat, there is no a members list
  if(not self.belongsToCommunity):
    return

  let communityDto = self.communityService.getCommunityById(self.sectionId)
  result = communityDto.members.map(x => x.id)

method getContactNameAndImage*(self: Controller, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactService.getContactNameAndImage(contactId)

method getStatusForContact*(self: Controller, contactId: string): StatusUpdateDto =
  return self.contactService.getStatusForContactWithId(contactId)