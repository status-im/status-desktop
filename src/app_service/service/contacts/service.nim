import NimQml, Tables, json, sequtils, strformat, chronicles, strutils, times, sugar

import ../../../app/global/global_singleton
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../settings/service as settings_service
import ./dto/contacts as contacts_dto
import ./dto/status_update as status_update_dto
import ./dto/contact_details
import ../../../backend/contacts as status_contacts
import ../../../backend/accounts as status_accounts
import ../../../backend/chat as status_chat
import ../../../backend/utils as status_utils

export contacts_dto, status_update_dto, contact_details

include async_tasks

logScope:
  topics = "contacts-service"

type
  ContactArgs* = ref object of Args
    contactId*: string

  ResolvedContactArgs* = ref object of Args
    pubkey*: string
    address*: string
    uuid*: string

  ContactsStatusUpdatedArgs* = ref object of Args
    statusUpdates*: seq[StatusUpdateDto]

# Local Constants:
const CheckStatusIntervalInMilliseconds = 5000 # 5 seconds, this is timeout how often do we check for user status.
const OnlineLimitInSeconds = int(5.5 * 60) # 5.5 minutes
const IdleLimitInSeconds = int(7 * 60) # 7 minutes

# Signals which may be emitted by this service:
const SIGNAL_ENS_RESOLVED* = "ensResolved"
const SIGNAL_CONTACT_ADDED* = "contactAdded"
const SIGNAL_CONTACT_BLOCKED* = "contactBlocked"
const SIGNAL_CONTACT_UNBLOCKED* = "contactUnblocked"
const SIGNAL_CONTACT_REMOVED* = "contactRemoved"
const SIGNAL_CONTACT_NICKNAME_CHANGED* = "contactNicknameChanged"
const SIGNAL_CONTACTS_STATUS_UPDATED* = "contactsStatusUpdated"
const SIGNAL_CONTACT_UPDATED* = "contactUpdated"
const SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED* = "loggedInUserImageChanged"


QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    settingsService: settings_service.Service
    contacts: Table[string, ContactsDto] # [contact_id, ContactsDto]
    contactsStatus: Table[string, StatusUpdateDto] # [contact_id, StatusUpdateDto]
    events: EventEmitter
    closingApp: bool

  # Forward declaration
  proc getContactById*(self: Service, id: string): ContactsDto
  proc saveContact(self: Service, contact: ContactsDto)
  proc startCheckingContactStatuses(self: Service)

  proc delete*(self: Service) =
    self.closingApp = true
    self.contacts.clear
    self.contactsStatus.clear
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      settingsService: settings_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.settingsService = settingsService
    result.threadpool = threadpool
    result.contacts = initTable[string, ContactsDto]()

  proc addContact(self: Service, contact: ContactsDto) =
    # Private proc, used for adding contacts only.
    self.contacts[contact.id] = contact
    self.contactsStatus[contact.id] = StatusUpdateDto(publicKey: contact.id, statusType: StatusType.Offline)

  proc fetchContacts*(self: Service) =
    try:
      let response = status_contacts.getContacts()

      let contacts = map(response.result.getElems(), proc(x: JsonNode): ContactsDto = x.toContactsDto())

      for contact in contacts:
        self.addContact(contact)

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
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

  proc init*(self: Service) =
    self.fetchContacts()
    self.doConnect()
    self.startCheckingContactStatuses()

    signalConnect(singletonInstance.userProfile, "imageChanged()", self, "onLoggedInUserImageChange()", 2)

  proc onLoggedInUserImageChange*(self: Service) {.slot.} =
    let data = Args()
    self.events.emit(SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED, data)

  proc getContacts*(self: Service): seq[ContactsDto] =
    return toSeq(self.contacts.values)

  proc getAddedContacts*(self: Service): seq[ContactsDto] =
    return self.getContacts().filter(x => x.added)

  proc getBlockedContacts*(self: Service): seq[ContactsDto] =
    return self.getContacts().filter(x => x.blocked)

  proc getContactsWhoAddedMe*(self: Service): seq[ContactsDto] =
    return self.getContacts().filter(x => x.hasAddedUs)

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

  proc generateIdenticon*(self: Service, publicKey: string): string =
    if(publicKey.len == 0):
      error "cannot generate an identicon from the empty public key"
      return
    return status_accounts.generateIdenticon(publicKey).result.getStr

  proc getContactById*(self: Service, id: string): ContactsDto =
    if(id == singletonInstance.userProfile.getPubKey()):
      # If we try to get the contact details of ourselves, just return our own info
      return ContactsDto(
        id: singletonInstance.userProfile.getPubKey(),
        name: singletonInstance.userProfile.getName(),
        identicon: singletonInstance.userProfile.getIdenticon(),
        alias: singletonInstance.userProfile.getUsername(),
        ensVerified: singletonInstance.userProfile.getEnsName().len > 0,
        image: Images(
          thumbnail: singletonInstance.userProfile.getThumbnailImage(),
          large: singletonInstance.userProfile.getLargeImage()
        )
      )

    ## Returns contact details based on passed id (public key)
    ## If we don't have stored contact localy or in the db then we create it based on public key.
    if(self.contacts.hasKey(id)):
      return self.contacts[id]

    result = self.fetchContact(id)
    if result.id.len == 0:
      let alias = self.generateAlias(id)
      let identicon = self.generateIdenticon(id)
      result = ContactsDto(
        id: id,
        identicon: identicon,
        alias: alias,
        ensVerified: false,
        added: false,
        blocked: false,
        hasAddedUs: false
      )
      self.addContact(result)

  proc getStatusForContactWithId*(self: Service, publicKey: string): StatusUpdateDto =
    # This method will fetch current accurate status from `status-go` once we add an api point there for it.
    if(not self.contactsStatus.hasKey(publicKey)):
      # following line ensures that we have added a contact before setting status for it
      discard self.getContactById(publicKey)

    return self.contactsStatus[publicKey]

  proc getContactNameAndImage*(self: Service, publicKey: string): tuple[name: string, image: string, isIdenticon: bool] =
    ## This proc should be used accross the app in order to have for the same contact
    ## same image and name displayed everywhere in the app.
    let contactDto = self.getContactById(publicKey)
    result.name = contactDto.userNameOrAlias()
    result.image = contactDto.identicon
    result.isIdenticon = contactDto.identicon.len > 0
    if(contactDto.image.thumbnail.len > 0):
      result.image = contactDto.image.thumbnail
      result.isIdenticon = false

  proc saveContact(self: Service, contact: ContactsDto) =
    # we must keep local contacts updated
    self.contacts[contact.id] = contact

  proc addContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    if not contact.added:
      contact.added = true
    else:
      contact.blocked = false

    let response = status_contacts.addContact(contact.id, contact.name)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error adding contact ", msg
      return
    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_ADDED, ContactArgs(contactId: contact.id))

  proc rejectContactRequest*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.hasAddedUs = false

    let response = status_contacts.rejectContactRequest(contact.id)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error rejecting contact ", msg
      return
    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_REMOVED, ContactArgs(contactId: contact.id))

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
    contact.blocked = false

    let response = status_contacts.unblockContact(contact.id)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error unblocking contact ", msg
      return
    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_UNBLOCKED, ContactArgs(contactId: contact.id))

  proc blockContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.blocked = true

    let response = status_contacts.blockContact(contact.id)
    if(not response.error.isNil):
      let msg = response.error.message
      error "error blocking contact ", msg
      return
    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_BLOCKED, ContactArgs(contactId: contact.id))

  proc removeContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.added = false
    contact.hasAddedUs = false

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
        uuid: jsonObj["uuid"].getStr)
    self.events.emit(SIGNAL_ENS_RESOLVED, data)

  proc resolveENS*(self: Service, value: string, uuid: string = "") =
    if(self.closingApp):
      return
    let arg = LookupContactTaskArg(
      tptr: cast[ByteAddress](lookupContactTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "ensResolved",
      value: value,
      chainId: self.settingsService.getCurrentNetworkId(),
      uuid: uuid
    )
    self.threadpool.start(arg)

  proc checkContactsStatus*(self: Service, response: string) {.slot.} =
    let nowInMyLocalZone = now()
    let timestampNow = uint64(nowInMyLocalZone.toTime().toUnix())
    var updatedStatuses: seq[StatusUpdateDto]
    for status in self.contactsStatus.mvalues:
      if(timestampNow - status.clock < uint64(OnlineLimitInSeconds)):
        if(status.statusType == StatusType.Online):
          continue
        else:
          status.statusType = StatusType.Online
          updatedStatuses.add(status)
      elif(timestampNow - status.clock < uint64(IdleLimitInSeconds)):
        if(status.statusType == StatusType.Idle):
          continue
        else:
          status.statusType = StatusType.Idle
          updatedStatuses.add(status)
      elif(status.statusType != StatusType.Offline):
        status.statusType = StatusType.Offline
        updatedStatuses.add(status)

    if(updatedStatuses.len > 0):
      let data = ContactsStatusUpdatedArgs(statusUpdates: updatedStatuses)
      self.events.emit(SIGNAL_CONTACTS_STATUS_UPDATED, data)

    self.startCheckingContactStatuses()

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
    let (name, icon, isIdenticon) = self.getContactNameAndImage(pubKey)
    result.displayName = name
    result.icon = icon
    result.isIdenticon = isIdenticon
    result.isCurrentUser = pubKey == singletonInstance.userProfile.getPubKey()
    result.details = self.getContactById(pubKey)
