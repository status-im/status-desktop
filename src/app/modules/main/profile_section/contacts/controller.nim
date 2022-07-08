import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/chat/service as chat_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    contactsService: contacts_service.Service
    chatService: chat_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.contactsService = contactsService
  result.chatService = chatService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactAdded(args.contactId)

  self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactBlocked(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNBLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUnblocked(args.contactId)

  self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactRemoved(args.contactId)

  self.events.on(SIGNAL_CONTACT_REJECTION_REMOVED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactRequestRejectionRemoved(args.contactId)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactNicknameChanged(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNTRUSTWORTHY) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactTrustStatusChanged(args.publicKey, args.isUntrustworthy)

  self.events.on(SIGNAL_CONTACT_TRUSTED) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactTrustStatusChanged(args.publicKey, args.isUntrustworthy)

  self.events.on(SIGNAL_REMOVED_TRUST_STATUS) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactTrustStatusChanged(args.publicKey, args.isUntrustworthy)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACT_VERIFICATION_DECLINED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onVerificationRequestDeclined(args.contactId)

  self.events.on(SIGNAL_CONTACT_VERIFICATION_ADDED) do(e: Args):
    var args = VerificationRequestArgs(e)
    self.delegate.onVerificationRequestUpdatedOrAdded(args.verificationRequest)

  self.events.on(SIGNAL_CONTACT_VERIFICATION_UPDATED) do(e: Args):
    var args = VerificationRequestArgs(e)
    self.delegate.onVerificationRequestUpdatedOrAdded(args.verificationRequest)

  self.events.on(SIGNAL_CONTACT_VERIFICATION_ACCEPTED) do(e: Args):
    var args = VerificationRequestArgs(e)
    self.delegate.onVerificationRequestUpdatedOrAdded(args.verificationRequest)

proc getContacts*(self: Controller, group: ContactsGroup): seq[ContactsDto] =
  return self.contactsService.getContactsByGroup(group)

proc getContact*(self: Controller, id: string): ContactsDto =
  return self.contactsService.getContactById(id)

proc getContactNameAndImage*(self: Controller, contactId: string):
    tuple[name: string, image: string, largeImage: string] =
  return self.contactsService.getContactNameAndImage(contactId)

proc unblockContact*(self: Controller, publicKey: string) =
  self.contactsService.unblockContact(publicKey)

proc blockContact*(self: Controller, publicKey: string) =
  self.contactsService.blockContact(publicKey)

proc removeContact*(self: Controller, publicKey: string) =
  self.contactsService.removeContact(publicKey)

proc changeContactNickname*(self: Controller, publicKey: string, nickname: string) =
  self.contactsService.changeContactNickname(publicKey, nickname)

proc sendContactRequest*(self: Controller, publicKey: string, message: string) =
  self.contactsService.sendContactRequest(publicKey, message)

proc acceptContactRequest*(self: Controller, publicKey: string) =
  self.contactsService.acceptContactRequest(publicKey)

proc dismissContactRequest*(self: Controller, publicKey: string) =
  self.contactsService.dismissContactRequest(publicKey)

proc removeContactRequestRejection*(self: Controller, publicKey: string) =
  self.contactsService.removeContactRequestRejection(publicKey)

proc switchToOrCreateOneToOneChat*(self: Controller, chatId: string) =
  self.chatService.switchToOrCreateOneToOneChat(chatId, "")

proc markUntrustworthy*(self: Controller, publicKey: string) =
  self.contactsService.markUntrustworthy(publicKey)

proc removeTrustStatus*(self: Controller, publicKey: string) =
  self.contactsService.removeTrustStatus(publicKey)

proc getVerificationRequestSentTo*(self: Controller, publicKey: string): VerificationRequest =
  self.contactsService.getVerificationRequestSentTo(publicKey)

proc getVerificationRequestFrom*(self: Controller, publicKey: string): VerificationRequest =
  self.contactsService.getVerificationRequestFrom(publicKey)

proc sendVerificationRequest*(self: Controller, publicKey: string, challenge: string) =
  self.contactsService.sendVerificationRequest(publicKey, challenge)

proc cancelVerificationRequest*(self: Controller, publicKey: string) =
  self.contactsService.cancelVerificationRequest(publicKey)

proc verifiedTrusted*(self: Controller, publicKey: string) =
  self.contactsService.verifiedTrusted(publicKey)

proc verifiedUntrustworthy*(self: Controller, publicKey: string) =
  self.contactsService.verifiedUntrustworthy(publicKey)

proc acceptVerificationRequest*(self: Controller, publicKey: string, response: string) =
  self.contactsService.acceptVerificationRequest(publicKey, response)

proc declineVerificationRequest*(self: Controller, publicKey: string) =
  self.contactsService.declineVerificationRequest(publicKey)

proc getReceivedVerificationRequests*(self: Controller): seq[VerificationRequest] =
  self.contactsService.getReceivedVerificationRequests()

proc hasReceivedVerificationRequestFrom*(self: Controller, fromId: string): bool =
  self.contactsService.hasReceivedVerificationRequestFrom(fromId)
