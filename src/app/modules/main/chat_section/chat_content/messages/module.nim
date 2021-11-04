import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../../shared_models/message_model
import ../../../../shared_models/message_item
import ../../../../../core/global_singleton

import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/message/service as message_service

import eventemitter

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, chatId: string, 
  belongsToCommunity: bool, chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, chatId, belongsToCommunity, communityService, 
  messageService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("messagesModule", self.viewVariant)
  
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.messagesDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method newMessagesLoaded*(self: Module, messages: seq[MessageDto], reactions: seq[ReactionDto], 
  pinnedMessages: seq[PinnedMessageDto]) = 
  var viewItems: seq[Item] 
  for m in messages:
    var item = initItem(m.id, m.`from`, m.alias, m.identicon, m.outgoingStatus, m.text, m.seen, m.timestamp, 
    m.contentType.ContentType, m.messageType)

    for r in reactions:
      if(r.messageId == m.id):
        # m.`from` should be replaced by appropriate ens/alias when we have that part refactored
        item.addReaction(r.emojiId, m.`from`, r.id)

    for p in pinnedMessages:
      if(p.message.id == m.id):
        item.pinned = true

    # messages are sorted from the most recent to the least recent one
    viewItems = item & viewItems

  self.view.model.prependItems(viewItems)

method toggleReaction*(self: Module, messageId: string, emojiId: int) =
  let item = self.view.model.getItemWithMessageId(messageId)
  let myName = "MY_NAME" #once we have "userProfile" merged, we will request alias/ens name from there
  if(item.shouldAddReaction(emojiId, myName)):
    self.controller.addReaction(messageId, emojiId)
  else:
    let reactionId = item.getReactionId(emojiId, myName)
    self.controller.removeReaction(messageId, reactionId)

method onReactionAdded*(self: Module, messageId: string, emojiId: int, reactionId: string) =
  let myName = "MY_NAME" #once we have "userProfile" merged, we will request alias/ens name from there
  self.view.model.addReaction(messageId, emojiId, myName, reactionId)

method onReactionRemoved*(self: Module, messageId: string, reactionId: string) =
  self.view.model.removeReaction(messageId, reactionId)

method pinUnpinMessage*(self: Module, messageId: string, pin: bool) =
  self.controller.pinUnpinMessage(messageId, pin)

method onPinUnpinMessage*(self: Module, messageId: string, pin: bool) =
  self.view.model.pinUnpinMessage(messageId, pin)