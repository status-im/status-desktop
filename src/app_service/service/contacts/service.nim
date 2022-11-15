import NimQml, Tables, json, sequtils, strformat, chronicles, strutils, times, sugar, std/times

import ../../../app/global/global_singleton
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../common/types as common_types
import ../../common/conversion as service_conversion

import ../activity_center/service as activity_center_service
import ../settings/service as settings_service
import ../network/service as network_service
import ../visual_identity/service as procs_from_visual_identity_service

import ./dto/contacts as contacts_dto
import ./dto/status_update as status_update_dto
import ./dto/contact_details
import ../../../backend/contacts as status_contacts
import ../../../backend/accounts as status_accounts

export contacts_dto, status_update_dto, contact_details

const PK_LENGTH_0X_INCLUDED = 132

include async_tasks

logScope:
  topics = "contacts-service"

type
  ContactArgs* = ref object of Args
    contactId*: string

  TrustArgs* = ref object of Args
    publicKey*: string
    isUntrustworthy*: bool

  ResolvedContactArgs* = ref object of Args
    pubkey*: string
    address*: string
    uuid*: string
    reason*: string

  ContactsStatusUpdatedArgs* = ref object of Args
    statusUpdates*: seq[StatusUpdateDto]

  VerificationRequestArgs* = ref object of Args
    verificationRequest*: VerificationRequest

# Signals which may be emitted by this service:
const SIGNAL_ENS_RESOLVED* = "ensResolved"
const SIGNAL_CONTACT_ADDED* = "contactAdded"
const SIGNAL_CONTACT_BLOCKED* = "contactBlocked"
const SIGNAL_CONTACT_UNBLOCKED* = "contactUnblocked"
const SIGNAL_CONTACT_REMOVED* = "contactRemoved"
const SIGNAL_CONTACT_REJECTION_REMOVED* = "contactRejectionRemoved"
const SIGNAL_CONTACT_NICKNAME_CHANGED* = "contactNicknameChanged"
const SIGNAL_CONTACTS_STATUS_UPDATED* = "contactsStatusUpdated"
const SIGNAL_CONTACT_UPDATED* = "contactUpdated"
const SIGNAL_LOGGEDIN_USER_NAME_CHANGED* = "loggedInUserNameChanged"
const SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED* = "loggedInUserImageChanged"
const SIGNAL_REMOVED_TRUST_STATUS* = "removedTrustStatus"
const SIGNAL_CONTACT_UNTRUSTWORTHY* = "contactUntrustworthy"
const SIGNAL_CONTACT_TRUSTED* = "contactTrusted"
const SIGNAL_CONTACT_VERIFIED* = "contactVerified"
const SIGNAL_CONTACT_VERIFICATION_SENT* = "contactVerificationRequestSent"
const SIGNAL_CONTACT_VERIFICATION_CANCELLED* = "contactVerificationRequestCancelled"
const SIGNAL_CONTACT_VERIFICATION_DECLINED* = "contactVerificationRequestDeclined"
const SIGNAL_CONTACT_VERIFICATION_ACCEPTED* = "contactVerificationRequestAccepted"
const SIGNAL_CONTACT_VERIFICATION_ADDED* = "contactVerificationRequestAdded"
const SIGNAL_CONTACT_VERIFICATION_UPDATED* = "contactVerificationRequestUpdated"

type
  ContactsGroup* {.pure.} = enum
    AllKnownContacts
    MyMutualContacts    
    IncomingPendingContactRequests
    OutgoingPendingContactRequests
    IncomingRejectedContactRequests
    OutgoingRejectedContactRequests
    BlockedContacts

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    networkService: network_service.Service
    settingsService: settings_service.Service
    activityCenterService: activity_center_service.Service
    contacts: Table[string, ContactsDto] # [contact_id, ContactsDto]
    contactsStatus: Table[string, StatusUpdateDto] # [contact_id, StatusUpdateDto]
    receivedIdentityRequests: Table[string, VerificationRequest] # [from_id, VerificationRequest]
    events: EventEmitter
    closingApp: bool
    imageServerUrl: string

  # Forward declaration
  proc getContactById*(self: Service, id: string): ContactsDto
  proc saveContact(self: Service, contact: ContactsDto)
  proc fetchReceivedVerificationRequests*(self: Service) : seq[VerificationRequest]

  proc delete*(self: Service) =
    self.closingApp = true
    self.contacts.clear
    self.contactsStatus.clear
    self.receivedIdentityRequests.clear
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      networkService: network_service.Service,
      settingsService: settings_service.Service,
      activityCenterService: activity_center_service.Service,
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.networkService = networkService
    result.settingsService = settingsService
    result.activityCenterService = activityCenterService
    result.threadpool = threadpool
    result.contacts = initTable[string, ContactsDto]()
    result.contactsStatus = initTable[string, StatusUpdateDto]()
    result.receivedIdentityRequests = initTable[string, VerificationRequest]()

  proc addContact(self: Service, contact: ContactsDto) =
    # Private proc, used for adding contacts only.
    self.contacts[contact.id] = contact
    self.contactsStatus[contact.id] = StatusUpdateDto(publicKey: contact.id, statusType: StatusType.Unknown)

  proc fetchContacts*(self: Service) =
    try:
      let response = status_contacts.getContacts()

      let contacts = map(response.result.getElems(), proc(x: JsonNode): ContactsDto = x.toContactsDto())

      for contact in contacts:
        self.addContact(contact)

      # Identity verifications
      for request in self.fetchReceivedVerificationRequests():
        self.receivedIdentityRequests[request.fromId] = request

    except Exception as e:
      let errDesription = e.msg
      error "error fetching contacts: ", errDesription
      return

  proc updateAndEmitStatuses(self: Service, statusUpdates: seq[StatusUpdateDto]) =
    for s in statusUpdates:
      if(not self.contactsStatus.hasKey(s.publicKey)):
        # we shouldn't be here ever, but the following line ensures we have added a contact before setting status for it
        discard self.getContactById(s.publicKey)

      self.contactsStatus[s.publicKey] = s

    let data = ContactsStatusUpdatedArgs(statusUpdates: statusUpdates)
    self.events.emit(SIGNAL_CONTACTS_STATUS_UPDATED, data)

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e:Args):
      var receivedData = MessageSignal(e)
      if(receivedData.statusUpdates.len > 0):
        self.updateAndEmitStatuses(receivedData.statusUpdates)

      if(receivedData.contacts.len > 0):
        for c in receivedData.contacts:
          let localContact = self.getContactById(c.id)
          var receivedContact = c

          receivedContact.localNickname = localContact.localNickname
          self.saveContact(receivedContact)

          # Check if the contact request was sent by us and if it was approved by the recipient
          if localContact.added and not localContact.hasAddedUs and receivedContact.hasAddedUs:
            singletonInstance.globalEvents.showAcceptedContactRequest(
              "Contact request accepted",
              fmt "{receivedContact.displayName} accepted your contact request",
              receivedContact.id)

          let data = ContactArgs(contactId: c.id)
          self.events.emit(SIGNAL_CONTACT_UPDATED, data)

      let myPubKey = singletonInstance.userProfile.getPubKey()
      if(receivedData.verificationRequests.len > 0):
        for request in receivedData.verificationRequests:
          if request.fromId == myPubKey:
            # TODO handle reacting to my own request later
            continue

          let data = VerificationRequestArgs(verificationRequest: request)
          let alreadyContains = self.receivedIdentityRequests.contains(request.fromId)
          self.receivedIdentityRequests[request.fromId] = request

          if alreadyContains:
            self.events.emit(SIGNAL_CONTACT_VERIFICATION_UPDATED, data)

            if request.status == VerificationStatus.Trusted:
              if self.contacts.hasKey(request.fromId):
                self.contacts[request.fromId].trustStatus = TrustStatus.Trusted
                self.contacts[request.fromId].verificationStatus = VerificationStatus.Trusted
              self.events.emit(SIGNAL_CONTACT_TRUSTED,
                TrustArgs(publicKey: request.fromId, isUntrustworthy: false))
              self.events.emit(SIGNAL_CONTACT_VERIFIED, ContactArgs(contactId: request.fromId))

            if request.status == VerificationStatus.Canceled:
              if self.contacts.hasKey(request.fromId):
                self.contacts[request.fromId].verificationStatus = VerificationStatus.Canceled
              self.events.emit(SIGNAL_CONTACT_VERIFICATION_CANCELLED, ContactArgs(contactId: request.fromId))

          else:
            self.events.emit(SIGNAL_CONTACT_VERIFICATION_ADDED, data)

    self.events.on(SignalType.StatusUpdatesTimedout.event) do(e:Args):
      var receivedData = StatusUpdatesTimedoutSignal(e)
      if(receivedData.statusUpdates.len > 0):
        self.updateAndEmitStatuses(receivedData.statusUpdates)

  proc setImageServerUrl(self: Service) =
    try:
      let response = status_contacts.getImageServerURL()
      self.imageServerUrl = response.result.getStr()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc init*(self: Service) =
    self.setImageServerUrl()
    self.fetchContacts()
    self.doConnect()

    signalConnect(singletonInstance.userProfile, "nameChanged()", self, "onLoggedInUserNameChange()", 2)
    signalConnect(singletonInstance.userProfile, "imageChanged()", self, "onLoggedInUserImageChange()", 2)

  proc onLoggedInUserNameChange*(self: Service) {.slot.} =
    let data = Args()
    self.events.emit(SIGNAL_LOGGEDIN_USER_NAME_CHANGED, data)

  proc onLoggedInUserImageChange*(self: Service) {.slot.} =
    let data = Args()
    self.events.emit(SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED, data)

  proc getContactsByGroup*(self: Service, group: ContactsGroup): seq[ContactsDto] =
    # Having this logic here we ensure that the same contact group in each part of the app will have the same list
    # of contacts. Be sure when you change any condition here.
    let myPubKey = singletonInstance.userProfile.getPubKey()
    let contacts = toSeq(self.contacts.values)
    if (group == ContactsGroup.IncomingPendingContactRequests):
      return contacts.filter(x => x.id != myPubKey and 
        x.isContactRequestReceived() and 
        not x.isContactRequestSent() and
        not x.isContactRemoved() and
        not x.isReceivedContactRequestRejected() and
        not x.isBlocked())
    elif (group == ContactsGroup.OutgoingPendingContactRequests):
      return contacts.filter(x => x.id != myPubKey and 
        x.isContactRequestSent() and 
        not x.isContactRequestReceived() and 
        # not x.isSentContactRequestRejected() and
        not x.isContactRemoved() and
        not x.isBlocked())
    elif (group == ContactsGroup.IncomingRejectedContactRequests):
      return contacts.filter(x => x.id != myPubKey and 
        x.isContactRequestReceived() and 
        x.isReceivedContactRequestRejected() and
        not x.isBlocked())
    # elif (group == ContactsGroup.OutgoingRejectedContactRequests):
    #   return contacts.filter(x => x.id != myPubKey and 
    #     x.isContactRequestSent() and 
    #     x.isSentContactRequestRejected() and
    #     not x.isBlocked())
    elif (group == ContactsGroup.BlockedContacts):
      return contacts.filter(x => x.id != myPubKey and 
        x.isBlocked())
    elif (group == ContactsGroup.MyMutualContacts):
      # we need to revise this when we introduce "identity verification" feature
      return contacts.filter(x => x.id != myPubKey and 
        x.isContact())
    elif (group == ContactsGroup.AllKnownContacts):
      return contacts

  proc fetchContact(self: Service, id: string): ContactsDto =
    try:
      let response = status_contacts.getContactByID(id)

      result = response.result.toContactsDto()
      if result.id.len == 0:
        return

      self.addContact(result)

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc generateAlias*(self: Service, publicKey: string): string =
    if(publicKey.len == 0):
      error "cannot generate an alias from the empty public key"
      return
    return status_accounts.generateAlias(publicKey).result.getStr

  proc getTrustStatus*(self: Service, publicKey: string): TrustStatus =
    try:
      let t = status_contacts.getTrustStatus(publicKey).result.getInt
      return t.toTrustStatus()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return TrustStatus.Unknown

  proc getContactById*(self: Service, id: string): ContactsDto =

    var pubkey = id

    if len(pubkey) == 0:
        return

    if service_conversion.isCompressedPubKey(id):
        pubkey = status_accounts.decompressPk(id).result

    if(pubkey == singletonInstance.userProfile.getPubKey()):
      # If we try to get the contact details of ourselves, just return our own info
      return ContactsDto(
        id: singletonInstance.userProfile.getPubKey(),
        displayName: singletonInstance.userProfile.getDisplayName(),
        name: singletonInstance.userProfile.getPreferredName(),
        alias: singletonInstance.userProfile.getUsername(),
        ensVerified: singletonInstance.userProfile.getPreferredName().len > 0,
        added: true,
        image: Images(
          thumbnail: singletonInstance.userProfile.getThumbnailImage(),
          large: singletonInstance.userProfile.getLargeImage()
        ),
        trustStatus: TrustStatus.Trusted,
        bio: self.settingsService.getBio(),
        socialLinks: self.settingsService.getSocialLinks()
      )

    ## Returns contact details based on passed id (public key)
    ## If we don't have stored contact localy or in the db then we create it based on public key.
    if(self.contacts.hasKey(pubkey)):
      return self.contacts[pubkey]

    result = self.fetchContact(pubkey)
    if result.id.len == 0:
      if(not pubkey.startsWith("0x")):
        debug "id is not in a hex format"
        return

      var num64: int64
      let parsedChars = parseHex(pubkey, num64)
      if(parsedChars != PK_LENGTH_0X_INCLUDED):
        debug "id doesn't have expected lenght"
        return

      let alias = self.generateAlias(pubkey)
      let trustStatus = self.getTrustStatus(pubkey)
      result = ContactsDto(
        id: pubkey,
        alias: alias,
        ensVerified: false,
        added: false,
        blocked: false,
        hasAddedUs: false,
        trustStatus: trustStatus
      )
      self.addContact(result)

  proc getStatusForContactWithId*(self: Service, publicKey: string): StatusUpdateDto =
    if publicKey == singletonInstance.userProfile.getPubKey():
      let currentUserStatus = self.settingsService.getCurrentUserStatus()
      return StatusUpdateDto(publicKey: singletonInstance.userProfile.getPubKey(),
        statusType: currentUserStatus.statusType,
        clock: currentUserStatus.clock.uint64,
        text: currentUserStatus.text)
    # This proc will fetch current accurate status from `status-go` once we add an api point there for it.
    if(not self.contactsStatus.hasKey(publicKey)):
      # following line ensures that we have added a contact before setting status for it
      discard self.getContactById(publicKey)

    return self.contactsStatus[publicKey]

  proc getContactNameAndImageInternal(self: Service, contactDto: ContactsDto):
      tuple[name: string, optionalName: string, image: string, largeImage: string] =
    ## This proc should be used accross the app in order to have for the same contact
    ## same image and name displayed everywhere in the app.
    result.name = contactDto.userDefaultDisplayName()
    result.optionalName = contactDto.userOptionalName()
    if(contactDto.image.thumbnail.len > 0):
      result.image = contactDto.image.thumbnail
    if(contactDto.image.large.len > 0):
      result.largeImage = contactDto.image.large

  proc getContactNameAndImage*(self: Service, publicKey: string):
      tuple[name: string, image: string, largeImage: string] =
    let contactDto = self.getContactById(publicKey)
    let tempRes = self.getContactNameAndImageInternal(contactDto)
    return (tempRes.name, tempRes.image, tempRes.largeImage)

  proc saveContact(self: Service, contact: ContactsDto) =
    # we must keep local contacts updated
    self.contacts[contact.id] = contact

  proc sendContactRequest*(self: Service, chatKey: string, message: string) =
    try:
      let publicKey = status_accounts.decompressPk(chatKey).result

      let response = status_contacts.sendContactRequest(publicKey, message)
      if(not response.error.isNil):
        let msg = response.error.message
        error "error sending contact request", msg
        return

      var contact = self.getContactById(publicKey)
      contact.added = true
      contact.blocked = false
      contact.removed = false
      self.saveContact(contact)
      self.events.emit(SIGNAL_CONTACT_ADDED, ContactArgs(contactId: contact.id))
    except Exception as e:
      error "an error occurred while sending contact request", msg=e.msg

  proc acceptContactRequest*(self: Service, publicKey: string) =
    try:
      # NOTE: publicKey used for accepting last request
      let response = status_contacts.acceptLatestContactRequestForContact(publicKey)
      if(not response.error.isNil):
        let msg = response.error.message
        error "error accepting contact request", msg
        return

      var contact = self.getContactById(publicKey)
      contact.added = true
      contact.removed = false
      self.saveContact(contact)
      self.events.emit(SIGNAL_CONTACT_ADDED, ContactArgs(contactId: contact.id))
      self.activityCenterService.parseACNotificationResponse(response)

    except Exception as e:
      error "an error occurred while accepting contact request", msg=e.msg

  proc dismissContactRequest*(self: Service, publicKey: string) =
    try:
      # NOTE: publicKey used for dismissing last request
      let response = status_contacts.dismissLatestContactRequestForContact(publicKey)
      if(not response.error.isNil):
        let msg = response.error.message
        error "error dismissing contact ", msg
        return
      var contact = self.getContactById(publicKey)
      contact.removed = true
      self.saveContact(contact)
      self.events.emit(SIGNAL_CONTACT_REMOVED, ContactArgs(contactId: contact.id))
      self.activityCenterService.parseACNotificationResponse(response)
    except Exception as e:
      error "an error occurred while dismissing contact request", msg=e.msg

  proc removeContactRequestRejection*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.removed = false

    # When we know what flags or what `status-go` end point we need to call, we should add
    # that call here.

    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_REJECTION_REMOVED, ContactArgs(contactId: contact.id))

  proc changeContactNickname*(self: Service, publicKey: string, nickname: string) =
    var contact = self.getContactById(publicKey)
    contact.localNickname = nickname

    let response = status_contacts.setContactLocalNickname(contact.id, contact.localNickname)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error setting local name ", msg
      return
    self.saveContact(contact)
    let data = ContactArgs(contactId: contact.id)
    self.events.emit(SIGNAL_CONTACT_NICKNAME_CHANGED, data)

  proc unblockContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)

    let response = status_contacts.unblockContact(contact.id)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error unblocking contact ", msg
      return

    contact.blocked = false
    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_UNBLOCKED, ContactArgs(contactId: contact.id))

  proc blockContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)

    let response = status_contacts.blockContact(contact.id)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error blocking contact ", msg
      return

    contact.blocked = true
    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_BLOCKED, ContactArgs(contactId: contact.id))

  proc removeContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)

    if contact.added:
      discard status_contacts.retractContactRequest(publicKey)

    contact.removed = true
    contact.added = false

    let response = status_contacts.removeContact(contact.id)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error removing contact ", msg
      return
    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_REMOVED, ContactArgs(contactId: contact.id))

  proc ensResolved*(self: Service, jsonObj: string) {.slot.} =
    let jsonObj = jsonObj.parseJson()
    let data = ResolvedContactArgs(
        pubkey: jsonObj["id"].getStr,
        address: jsonObj["address"].getStr,
        uuid: jsonObj["uuid"].getStr,
        reason: jsonObj["reason"].getStr)
    self.events.emit(SIGNAL_ENS_RESOLVED, data)

  proc resolveENS*(self: Service, value: string, uuid: string = "", reason = "") =
    if(self.closingApp):
      return
    let arg = LookupContactTaskArg(
      tptr: cast[ByteAddress](lookupContactTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "ensResolved",
      value: value,
      chainId: self.networkService.getNetworkForEns().chainId,
      uuid: uuid,
      reason: reason
    )
    self.threadpool.start(arg)

  proc emitCurrentUserStatusChanged*(self: Service, currentStatusUser: CurrentUserStatus) =
    let currentUserStatusUpdate = StatusUpdateDto(publicKey: singletonInstance.userProfile.getPubKey(),
                                                  statusType: currentStatusUser.statusType,
                                                  clock: currentStatusUser.clock.uint64,
                                                  text: currentStatusUser.text)
    let data = ContactsStatusUpdatedArgs(statusUpdates: @[currentUserStatusUpdate])
    self.events.emit(SIGNAL_CONTACTS_STATUS_UPDATED, data)

  proc getContactDetails*(self: Service, pubKey: string): ContactDetails =
    result = ContactDetails()
    let contactDto = self.getContactById(pubKey)
    let (name, optionalName, icon, _) = self.getContactNameAndImageInternal(contactDto)
    result.defaultDisplayName = name
    result.optionalName = optionalName
    result.icon = icon
    result.colorId = procs_from_visual_identity_service.colorIdOf(pubKey)
    result.isCurrentUser = pubKey == singletonInstance.userProfile.getPubKey()
    result.details = contactDto

  proc markUntrustworthy*(self: Service, publicKey: string) =
    let response = status_contacts.markUntrustworthy(publicKey)
    if not response.error.isNil:
      let msg = response.error.message
      error "error marking as untrustworthy ", msg
      return

    if self.contacts.hasKey(publicKey):
      self.contacts[publicKey].trustStatus = TrustStatus.Untrustworthy

    self.events.emit(SIGNAL_CONTACT_UNTRUSTWORTHY,
      TrustArgs(publicKey: publicKey, isUntrustworthy: true))

  proc verifiedTrusted*(self: Service, publicKey: string) =
    try:
      var response = status_contacts.getVerificationRequestSentTo(publicKey)
      if not response.error.isNil:
        let msg = response.error.message
        raise newException(RpcException, msg)

      let request = response.result.toVerificationRequest()

      response = status_contacts.verifiedTrusted(request.id)
      if not response.error.isNil:
        let msg = response.error.message
        raise newException(RpcException, msg)
      self.activityCenterService.parseACNotificationResponse(response)

      if self.contacts.hasKey(publicKey):
        self.contacts[publicKey].trustStatus = TrustStatus.Trusted
        self.contacts[publicKey].verificationStatus = VerificationStatus.Trusted

        self.events.emit(SIGNAL_CONTACT_TRUSTED,
          TrustArgs(publicKey: publicKey, isUntrustworthy: false))
        self.events.emit(SIGNAL_CONTACT_VERIFIED, ContactArgs(contactId: publicKey))
    except Exception as e:
      error "error verified trusted request", msg=e.msg

  proc verifiedUntrustworthy*(self: Service, publicKey: string) =
    try:
      var response = status_contacts.getVerificationRequestSentTo(publicKey)
      if not response.error.isNil:
        let msg = response.error.message
        raise newException(RpcException, msg)

      let request = response.result.toVerificationRequest()

      response = status_contacts.verifiedUntrustworthy(request.id)
      if not response.error.isNil:
        let msg = response.error.message
        raise newException(RpcException, msg)
      self.activityCenterService.parseACNotificationResponse(response)

      if self.contacts.hasKey(publicKey):
        self.contacts[publicKey].trustStatus = TrustStatus.Untrustworthy
        self.contacts[publicKey].verificationStatus = VerificationStatus.Untrustworthy

        self.events.emit(SIGNAL_CONTACT_UNTRUSTWORTHY,
          TrustArgs(publicKey: publicKey, isUntrustworthy: true))
        self.events.emit(SIGNAL_CONTACT_VERIFIED, ContactArgs(contactId: publicKey))
    except Exception as e:
      error "error verified untrustworthy request", msg=e.msg

  proc removeTrustStatus*(self: Service, publicKey: string) =
    let response = status_contacts.removeTrustStatus(publicKey)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error removing trust status", msg
      return

    if self.contacts.hasKey(publicKey):
      self.contacts[publicKey].trustStatus = TrustStatus.Unknown
      if self.contacts[publicKey].verificationStatus == VerificationStatus.Verified:
        self.contacts[publicKey].verificationStatus = VerificationStatus.Unverified

    self.events.emit(SIGNAL_REMOVED_TRUST_STATUS,
      TrustArgs(publicKey: publicKey, isUntrustworthy: false))

  proc getVerificationRequestSentTo*(self: Service, publicKey: string): VerificationRequest =
    try:
      let response = status_contacts.getVerificationRequestSentTo(publicKey)
      return response.result.toVerificationRequest()
    except Exception as e:
      let errDesription = e.msg
      error "error obtaining verification request", errDesription
      return

  proc getVerificationRequestFrom*(self: Service, publicKey: string): VerificationRequest =
    try:
      if (self.receivedIdentityRequests.contains(publicKey)):
        return self.receivedIdentityRequests[publicKey]

      let response = status_contacts.getVerificationRequestFrom(publicKey)
      if not response.result.isNil and response.result.kind == JObject:
        result = response.result.toVerificationRequest()
        self.receivedIdentityRequests[publicKey] = result
    except Exception as e:
      let errDesription = e.msg
      error "error obtaining verification request", errDesription

  proc fetchReceivedVerificationRequests*(self: Service): seq[VerificationRequest] =
    try:
      let response = status_contacts.getReceivedVerificationRequests()

      for request in response.result:
        result.add(request.toVerificationRequest())
    except Exception as e:
      let errDesription = e.msg
      error "error obtaining verification requests", errDesription

  proc getReceivedVerificationRequests*(self: Service): seq[VerificationRequest] =
    result = toSeq(self.receivedIdentityRequests.values)

  proc sendVerificationRequest*(self: Service, publicKey: string, challenge: string) =
    try:
      let response = status_contacts.sendVerificationRequest(publicKey, challenge)
      if(not response.error.isNil):
        let msg = response.error.message
        error "error sending contact verification request", msg
        return

      var contact = self.getContactById(publicKey)
      contact.verificationStatus = VerificationStatus.Verifying
      self.saveContact(contact)

      self.events.emit(SIGNAL_CONTACT_VERIFICATION_SENT, ContactArgs(contactId: publicKey))
      self.activityCenterService.parseACNotificationResponse(response)
    except Exception as e:
      error "Error sending verification request", msg = e.msg

  proc cancelVerificationRequest*(self: Service, publicKey: string) =
    try:
      var response = status_contacts.getVerificationRequestSentTo(publicKey)
      if not response.error.isNil:
        let msg = response.error.message
        raise newException(RpcException, msg)

      let request = response.result.toVerificationRequest()

      response = status_contacts.cancelVerificationRequest(request.id)
      if not response.error.isNil:
        let msg = response.error.message
        error "error sending contact verification request", msg
        return

      var contact = self.getContactById(publicKey)
      contact.verificationStatus = VerificationStatus.Unverified
      self.saveContact(contact)

      self.events.emit(SIGNAL_CONTACT_VERIFICATION_CANCELLED, ContactArgs(contactId: publicKey))
      self.activityCenterService.parseACNotificationResponse(response)
    except Exception as e:
      error "Error canceling verification request", msg = e.msg

  proc acceptVerificationRequest*(self: Service, publicKey: string, responseText: string) =
    try:
      if not self.receivedIdentityRequests.contains(publicKey):
        raise newException(ValueError, fmt"No verification request for public key: `{publicKey}`")

      var request = self.receivedIdentityRequests[publicKey]
      let response = status_contacts.acceptVerificationRequest(request.id, responseText)
      if(not response.error.isNil):
        let msg = response.error.message
        raise newException(RpcException, msg)

      request.status = VerificationStatus.Verified
      request.response = responseText
      request.repliedAt = getTime().toUnix * 1000
      self.receivedIdentityRequests[publicKey] = request

      self.events.emit(SIGNAL_CONTACT_VERIFICATION_ACCEPTED,
        VerificationRequestArgs(verificationRequest: request))
      self.activityCenterService.parseACNotificationResponse(response)
    except Exception as e:
      error "error accepting contact verification request", msg=e.msg

  proc declineVerificationRequest*(self: Service, publicKey: string) =
    try:
      if not self.receivedIdentityRequests.contains(publicKey):
        raise newException(ValueError, fmt"No verification request for public key: `{publicKey}`")

      var request = self.receivedIdentityRequests[publicKey]
      let response = status_contacts.declineVerificationRequest(request.id)
      if(not response.error.isNil):
        let msg = response.error.message
        raise newException(RpcException, msg)

      request.status = VerificationStatus.Declined
      self.receivedIdentityRequests[publicKey] = request

      self.events.emit(SIGNAL_CONTACT_VERIFICATION_DECLINED, ContactArgs(contactId: publicKey))
      self.activityCenterService.parseACNotificationResponse(response)
    except Exception as e:
      error "error declining contact verification request", msg=e.msg
