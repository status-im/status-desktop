import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../../shared_models/message_model
import ../../../../shared_models/message_item
import ../../../../../global/global_singleton

import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/message/service as message_service

import eventemitter

export io_interface

const CHAT_IDENTIFIER_MESSAGE_ID = "chat-identifier-message-id"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, chatId: string, 
  belongsToCommunity: bool, contactService: contact_service.Service, chatService: chat_service.Service,
  messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, chatId, belongsToCommunity, contactService, chatService,
  messageService)
  result.moduleLoaded = false

# Forward declaration
proc createChatIdentifierItem(self: Module): Item

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  # The first message in the model must be always ChatIdentifier message.
  self.view.model().appendItem(self.createChatIdentifierItem())

  self.moduleLoaded = true
  self.delegate.messagesDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

proc createChatIdentifierItem(self: Module): Item =
  let chatDto = self.controller.getChatDetails()
  var chatName = chatDto.name
  var chatIcon = chatDto.identicon
  var isIdenticon = false
  if(chatDto.chatType == ChatType.OneToOne):
    (chatName, chatIcon, isIdenticon) = self.controller.getOneToOneChatNameAndImage()

  result = initItem(CHAT_IDENTIFIER_MESSAGE_ID, "", chatDto.id, chatName, "", chatIcon, isIdenticon, false, "", "", "", 
  true, 0, ContentType.ChatIdentifier, -1)

method newMessagesLoaded*(self: Module, messages: seq[MessageDto], reactions: seq[ReactionDto], 
  pinnedMessages: seq[PinnedMessageDto]) = 
  var viewItems: seq[Item]
  
  for m in messages:
    let sender = self.controller.getContactById(m.`from`)
    let senderDisplayName = sender.userNameOrAlias()
    let amISender = m.`from` == singletonInstance.userProfile.getPubKey()
    var senderIcon = sender.identicon
    var isSenderIconIdenticon = sender.identicon.len > 0
    if(sender.image.thumbnail.len > 0): 
      senderIcon = sender.image.thumbnail
      isSenderIconIdenticon = false

    var item = initItem(m.id, m.responseTo, m.`from`, senderDisplayName, sender.localNickname, senderIcon, 
    isSenderIconIdenticon, amISender, m.outgoingStatus, m.text, m.image, m.seen, m.timestamp, m.contentType.ContentType, 
    m.messageType)

    for r in reactions:
      if(r.messageId == m.id):
        item.addReaction(r.emojiId, m.`from`, r.id)

    for p in pinnedMessages:
      if(p.message.id == m.id):
        item.pinned = true

    # messages are sorted from the most recent to the least recent one
    viewItems.add(item)

  # ChatIdentifier message will be always the first message (the oldest one)
  viewItems.add(self.createChatIdentifierItem())
  # Delete the old ChatIdentifier message first
  self.view.model().removeItem(CHAT_IDENTIFIER_MESSAGE_ID)
  # Add new loaded messages
  self.view.model().prependItems(viewItems)

method toggleReaction*(self: Module, messageId: string, emojiId: int) =
  let item = self.view.model().getItemWithMessageId(messageId)
  let myName = singletonInstance.userProfile.getName()
  if(item.shouldAddReaction(emojiId, myName)):
    self.controller.addReaction(messageId, emojiId)
  else:
    let reactionId = item.getReactionId(emojiId, myName)
    self.controller.removeReaction(messageId, reactionId)

method onReactionAdded*(self: Module, messageId: string, emojiId: int, reactionId: string) =
  let myName = singletonInstance.userProfile.getName()
  self.view.model().addReaction(messageId, emojiId, myName, reactionId)

method onReactionRemoved*(self: Module, messageId: string, reactionId: string) =
  self.view.model().removeReaction(messageId, reactionId)

method getNamesReactedWithEmojiIdForMessageId*(self: Module, messageId: string, emojiId: int): seq[string] = 
  let pubKeysForEmojiId = self.view.model().getPubKeysReactedWithEmojiIdForMessageId(messageId, emojiId)
  for pk in pubKeysForEmojiId:
    let (name, _, _) = self.controller.getContactNameAndImage(pk)
    result.add(name)

method pinUnpinMessage*(self: Module, messageId: string, pin: bool) =
  self.controller.pinUnpinMessage(messageId, pin)

method onPinUnpinMessage*(self: Module, messageId: string, pin: bool) =
  self.view.model().pinUnpinMessage(messageId, pin)

method getChatType*(self: Module): int =
  let chatDto = self.controller.getChatDetails()
  return chatDto.chatType.int

method getChatColor*(self: Module): string =
  let chatDto = self.controller.getChatDetails()
  return chatDto.color

method amIChatAdmin*(self: Module): bool =
  return false

method getNumberOfPinnedMessages*(self: Module): int =
  return self.controller.getNumOfPinnedMessages()