import NimQml, tables
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../../../global/global_singleton
import ../../../../../core/eventemitter

import ../../../../../../app_service/service/settings/service as settings_service
import ../../../../../../app_service/service/message/service as message_service
import ../../../../../../app_service/service/message/dto/link_preview
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/contacts/service as contact_service
export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    sectionId: string,
    chatId: string,
    belongsToCommunity: bool,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    contactService: contact_service.Service,
    messageService: message_service.Service,
    settingsService: settings_service.Service
    ):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, sectionId, chatId, belongsToCommunity, chatService, communityService, contactService, messageService, settingsService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("chatSectionChatContentInputArea", self.viewVariant)

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.inputAreaDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

proc getChatId*(self: Module): string =
  return self.controller.getChatId()

method sendImages*(self: Module, imagePathsAndDataJson: string, msg: string, replyTo: string, linkPreviews: seq[LinkPreview]) =
  self.controller.sendImages(imagePathsAndDataJson, msg, replyTo, singletonInstance.userProfile.getPreferredName(), linkPreviews)

method sendChatMessage*(
    self: Module,
    msg: string,
    replyTo: string,
    contentType: int,
    linkPreviews: seq[LinkPreview]) =
  self.controller.sendChatMessage(msg, replyTo, contentType,
    singletonInstance.userProfile.getPreferredName(), linkPreviews)

method requestAddressForTransaction*(self: Module, fromAddress: string, amount: string, tokenAddress: string) =
  self.controller.requestAddressForTransaction(fromAddress, amount, tokenAddress)

method requestTransaction*(self: Module, fromAddress: string, amount: string, tokenAddress: string) =
  self.controller.requestTransaction(fromAddress, amount, tokenAddress)

method declineRequestTransaction*(self: Module, messageId: string) =
  self.controller.declineRequestTransaction(messageId)

method declineRequestAddressForTransaction*(self: Module, messageId: string) =
  self.controller.declineRequestAddressForTransaction(messageId)

method acceptRequestAddressForTransaction*(self: Module, messageId: string, address: string) =
  self.controller.acceptRequestAddressForTransaction(messageId, address)

method acceptRequestTransaction*(self: Module, transactionHash: string, messageId: string, signature: string) =
  self.controller.acceptRequestTransaction(transactionHash, messageId, signature)

method setText*(self: Module, text: string, unfurlNewUrls: bool) =
  self.controller.setText(text, unfurlNewUrls)

method getPlainText*(self: Module): string =
  return self.view.getPlainText()

method clearLinkPreviewCache*(self: Module) {.slot.} =
  self.controller.clearLinkPreviewCache()

method updateLinkPreviewsFromCache*(self: Module, urls: seq[string]) =
  self.view.updateLinkPreviewsFromCache(urls)

method setLinkPreviewUrls*(self: Module, urls: seq[string]) =
  self.view.setLinkPreviewUrls(urls)

method linkPreviewsFromCache*(self: Module, urls: seq[string]): Table[string, LinkPreview] =
  return self.controller.linkPreviewsFromCache(urls)

method reloadUnfurlingPlan*(self: Module) =
  self.controller.reloadUnfurlingPlan()

method loadLinkPreviews*(self: Module, urls: seq[string]) =
  self.controller.loadLinkPreviews(urls)

method getLinkPreviewEnabled*(self: Module): bool =
  return self.controller.getLinkPreviewEnabled()

method setLinkPreviewEnabled*(self: Module, enabled: bool) =
  self.controller.setLinkPreviewEnabled(enabled)

method setAskToEnableLinkPreview*(self: Module, value: bool) =
  self.view.setAskToEnableLinkPreview(value)

method setLinkPreviewEnabledForThisMessage*(self: Module, value: bool) =
  self.controller.setLinkPreviewEnabledForThisMessage(value)

method setUrls*(self: Module, urls: seq[string]) =
  self.view.setUrls(urls)

method getContactDetails*(self: Module, contactId: string): ContactDetails =
  return self.controller.getContactDetails(contactId)

method onSendingMessageSuccess*(self: Module) =
  self.view.emitSendingMessageSuccess()

method onSendingMessageFailure*(self: Module) =
  self.view.emitSendingMessageFailure()
