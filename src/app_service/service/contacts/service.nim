import NimQml, Tables, json, sequtils, strformat, chronicles, strutils, times, sugar, std/times

import ../../../app/global/global_singleton
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../common/types as common_types

import ../settings/service as settings_service
import ../network/service as network_service
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

# Local Constants:
const CheckStatusIntervalInMilliseconds = 5000 # 5 seconds, this is timeout how often do we check for user status.
const FiveMinsOnlineLimitInSeconds = int(5 * 60) # 5 minutes
const TwoWeeksOnlineLimitInSeconds = int(14 * 24 * 60 * 60) # 2 weeks

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
    contacts: Table[string, ContactsDto] # [contact_id, ContactsDto]
    contactsStatus: Table[string, StatusUpdateDto] # [contact_id, StatusUpdateDto]
    receivedIdentityRequests: Table[string, VerificationRequest] # [from_id, VerificationRequest]
    events: EventEmitter
    closingApp: bool
    imageServerUrl: string

  # Forward declaration
  proc getContactById*(self: Service, id: string): ContactsDto
  proc saveContact(self: Service, contact: ContactsDto)
  proc startCheckingContactStatuses(self: Service)
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
      settingsService: settings_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.networkService = networkService
    result.settingsService = settingsService
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

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e:Args):
      var receivedData = MessageSignal(e)
      if(receivedData.statusUpdates.len > 0):
        for s in receivedData.statusUpdates:
          if(not self.contactsStatus.hasKey(s.publicKey)):
            # we shouldn't be here ever, but the following line ensures we have added a contact before setting status for it
            discard self.getContactById(s.publicKey)

          self.contactsStatus[s.publicKey] = s

        let data = ContactsStatusUpdatedArgs(statusUpdates: receivedData.statusUpdates)
        self.events.emit(SIGNAL_CONTACTS_STATUS_UPDATED, data)

      if(receivedData.contacts.len > 0):
        for c in receivedData.contacts:
          let localContact = self.getContactById(c.id)
          var receivedContact = c
          receivedContact.localNickname = localContact.localNickname
          self.saveContact(receivedContact)

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
          else:
            self.events.emit(SIGNAL_CONTACT_VERIFICATION_ADDED, data)

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
    self.startCheckingContactStatuses()

    signalConnect(singletonInstance.userProfile, "imageChanged()", self, "onLoggedInUserImageChange()", 2)

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
        # not x.isReceivedContactRequestRejected() and
        not x.isBlocked())
    elif (group == ContactsGroup.OutgoingPendingContactRequests):
      return contacts.filter(x => x.id != myPubKey and 
        x.isContactRequestSent() and 
        not x.isContactRequestReceived() and 
        # not x.isSentContactRequestRejected() and
        not x.isContactRemoved() and
        not x.isBlocked())
    # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
    # elif (group == ContactsGroup.IncomingRejectedContactRequests):
    #   return contacts.filter(x => x.id != myPubKey and 
    #     x.isContactRequestReceived() and 
    #     x.isReceivedContactRequestRejected() and
    #     not x.isBlocked())
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
    if(id == singletonInstance.userProfile.getPubKey()):
      # If we try to get the contact details of ourselves, just return our own info
      return ContactsDto(
        id: singletonInstance.userProfile.getPubKey(),
        displayName: singletonInstance.userProfile.getDisplayName(),
        name: singletonInstance.userProfile.getEnsName(),
        alias: singletonInstance.userProfile.getUsername(),
        ensVerified: singletonInstance.userProfile.getEnsName().len > 0,
        added: true,
        image: Images(
          thumbnail: singletonInstance.userProfile.getThumbnailImage(),
          large: singletonInstance.userProfile.getLargeImage()
        ),
        trustStatus: TrustStatus.Trusted
      )

    ## Returns contact details based on passed id (public key)
    ## If we don't have stored contact localy or in the db then we create it based on public key.
    if(self.contacts.hasKey(id)):
      return self.contacts[id]

    result = self.fetchContact(id)
    if result.id.len == 0:
      if(not id.startsWith("0x")):
        debug "id is not in a hex format"
        return

      var num64: int64
      let parsedChars = parseHex(id, num64)
      if(parsedChars != PK_LENGTH_0X_INCLUDED):
        debug "id doesn't have expected lenght"
        return

      let alias = self.generateAlias(id)
      let trustStatus = self.getTrustStatus(id)
      result = ContactsDto(
        id: id,
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

  proc getContactNameAndImage*(self: Service, publicKey: string):
      tuple[name: string, image: string, largeImage: string] =
    ## This proc should be used accross the app in order to have for the same contact
    ## same image and name displayed everywhere in the app.
    let contactDto = self.getContactById(publicKey)
    result.name = contactDto.userNameOrAlias()
    if(contactDto.image.thumbnail.len > 0):
      result.image = contactDto.image.thumbnail
    if(contactDto.image.large.len > 0):
      result.largeImage = contactDto.image.large

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

  proc checkContactsStatus*(self: Service, response: string) {.slot.} =
    let nowInMyLocalZone = now()
    let timestampNow = uint64(nowInMyLocalZone.toTime().toUnix())
    var updatedStatuses: seq[StatusUpdateDto]
    for status in self.contactsStatus.mvalues:
      if((timestampNow - status.clock > uint64(FiveMinsOnlineLimitInSeconds) and status.statusType == StatusType.Automatic) or
         (timestampNow - status.clock > uint64(TwoWeeksOnlineLimitInSeconds) and status.statusType == StatusType.AlwaysOnline)):
        status.statusType = StatusType.Inactive
        updatedStatuses.add(status)

    if(updatedStatuses.len > 0):
      let data = ContactsStatusUpdatedArgs(statusUpdates: updatedStatuses)
      self.events.emit(SIGNAL_CONTACTS_STATUS_UPDATED, data)

    self.startCheckingContactStatuses()

  proc emitCurrentUserStatusChanged*(self: Service, currentStatusUser: CurrentUserStatus) =
    let currentUserStatusUpdate = StatusUpdateDto(publicKey: singletonInstance.userProfile.getPubKey(),
                                                  statusType: currentStatusUser.statusType,
                                                  clock: currentStatusUser.clock.uint64,
                                                  text: currentStatusUser.text)
    let data = ContactsStatusUpdatedArgs(statusUpdates: @[currentUserStatusUpdate])
    self.events.emit(SIGNAL_CONTACTS_STATUS_UPDATED, data)

  proc startCheckingContactStatuses(self: Service) =
    if(self.closingApp):
      return

    let arg = TimerTaskArg(
      tptr: cast[ByteAddress](timerTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "checkContactsStatus",
      timeoutInMilliseconds: CheckStatusIntervalInMilliseconds
    )
    self.threadpool.start(arg)

  proc getContactDetails*(self: Service, pubKey: string): ContactDetails =
    result = ContactDetails()
    let (name, icon, _) = self.getContactNameAndImage(pubKey)
    result.displayName = name
    result.icon = icon
    result.isCurrentUser = pubKey == singletonInstance.userProfile.getPubKey()
    result.details = self.getContactById(pubKey)

  proc markUntrustworthy*(self: Service, publicKey: string) =
    let response = status_contacts.markUntrustworthy(publicKey)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error marking as untrustworthy ", msg
      return

    if self.contacts.hasKey(publicKey):
      self.contacts[publicKey].trustStatus = TrustStatus.Untrustworthy

    self.events.emit(SIGNAL_CONTACT_UNTRUSTWORTHY,
      TrustArgs(publicKey: publicKey, isUntrustworthy: true))

  proc verifiedTrusted*(self: Service, publicKey: string) =
    let response = status_contacts.verifiedTrusted(publicKey)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error confirming identity ", msg
      return

    if self.contacts.hasKey(publicKey):
      self.contacts[publicKey].trustStatus = TrustStatus.Trusted
      self.contacts[publicKey].verificationStatus = VerificationStatus.Trusted

    self.events.emit(SIGNAL_CONTACT_TRUSTED,
      TrustArgs(publicKey: publicKey, isUntrustworthy: false))
    self.events.emit(SIGNAL_CONTACT_VERIFIED, ContactArgs(contactId: publicKey))

  proc verifiedUntrustworthy*(self: Service, publicKey: string) =
    let response = status_contacts.verifiedUntrustworthy(publicKey)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error confirming identity ", msg
      return

    if self.contacts.hasKey(publicKey):
      self.contacts[publicKey].trustStatus = TrustStatus.Untrustworthy
      self.contacts[publicKey].verificationStatus = VerificationStatus.Verified

    self.events.emit(SIGNAL_CONTACT_UNTRUSTWORTHY,
      TrustArgs(publicKey: publicKey, isUntrustworthy: true))
    self.events.emit(SIGNAL_CONTACT_VERIFIED, ContactArgs(contactId: publicKey))

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

  proc hasReceivedVerificationRequestFrom*(self: Service, fromId: string): bool =
    result = self.receivedIdentityRequests.contains(fromId)
    
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
    except Exception as e:
      error "Error sending verification request", msg = e.msg

  proc cancelVerificationRequest*(self: Service, publicKey: string) =
    try:
      let response = status_contacts.cancelVerificationRequest(publicKey)
      if(not response.error.isNil):
        let msg = response.error.message
        error "error sending contact verification request", msg
        return

      var contact = self.getContactById(publicKey)
      contact.verificationStatus = VerificationStatus.Unverified
      self.saveContact(contact)
      
      self.events.emit(SIGNAL_CONTACT_VERIFICATION_CANCELLED, ContactArgs(contactId: publicKey))
    except Exception as e:
      error "Error canceling verification request", msg = e.msg

  proc acceptVerificationRequest*(self: Service, publicKey: string, responseText: string) =
    try:
      let response = status_contacts.acceptVerificationRequest(publicKey, responseText)
      if(not response.error.isNil):
        let msg = response.error.message
        raise newException(RpcException, msg)

      var request = self.receivedIdentityRequests[publicKey]
      request.status = VerificationStatus.Verified
      request.response = responseText
      request.repliedAt = getTime().toUnix * 1000
      self.receivedIdentityRequests[publicKey] = request
      
      self.events.emit(SIGNAL_CONTACT_VERIFICATION_ACCEPTED,
        VerificationRequestArgs(verificationRequest: request))
    except Exception as e:
      error "error accepting contact verification request", msg=e.msg

  proc declineVerificationRequest*(self: Service, publicKey: string) =
    try:
      let response = status_contacts.declineVerificationRequest(publicKey)
      if(not response.error.isNil):
        let msg = response.error.message
        raise newException(RpcException, msg)

      var request = self.receivedIdentityRequests[publicKey]
      request.status = VerificationStatus.Declined
      self.receivedIdentityRequests[publicKey] = request
      
      self.events.emit(SIGNAL_CONTACT_VERIFICATION_DECLINED, ContactArgs(contactId: publicKey))
    except Exception as e:
      error "error declining contact verification request", msg=e.msg
    