import NimQml, chronicles
import Tables

import ../../../../../../app_service/service/contacts/dto/contacts

type
  ContactRoles {.pure.} = enum
    PubKey = UserRole + 1
    Name = UserRole + 2,
    Address = UserRole + 3
    Identicon = UserRole + 4
    IsContact = UserRole + 5
    IsBlocked = UserRole + 6
    Alias = UserRole + 7
    EnsVerified = UserRole + 8
    LocalNickname = UserRole + 9
    ThumbnailImage = UserRole + 10
    LargeImage = UserRole + 11
    RequestReceived = UserRole + 12

QtObject:
  type ContactList* = ref object of QAbstractListModel
    contacts*: seq[ContactsDto]

  proc setup(self: ContactList) = self.QAbstractListModel.setup

  proc delete(self: ContactList) =
    self.contacts = @[]
    self.QAbstractListModel.delete

  proc newContactList*(): ContactList =
    new(result, delete)
    # TODO: (rramos) contacts should be a table[string, ContactsDto] instead, with the key being the public key
    # This is to optimize determining if a contact is part of the contact list or not
    # (including those that do not have a system tag)
    result.contacts = @[]
    result.setup

  method rowCount(self: ContactList, index: QModelIndex = nil): int =
    return self.contacts.len

  proc countChanged*(self: ContactList) {.signal.}

  proc count*(self: ContactList): int {.slot.}  =
    self.contacts.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  proc userName*(self: ContactList, pubKey: string, defaultValue: string = ""): string {.slot.} =
    for contact in self.contacts:
      if(contact.id != pubKey): continue
      return userNameOrAlias(contact)
    return defaultValue

  proc getContactIndexByPubkey(self: ContactList, pubkey: string): int {.slot.} =
    var i = 0
    for contact in self.contacts:
      if (contact.id == pubkey):
        return i
      i = i + 1
    return -1 

  proc rowData(self: ContactList, index: int, column: string): string {.slot.} =
    let contact = self.contacts[index]
    case column:
      of "name": result = userNameOrAlias(contact)
      of "address": result = contact.id
      of "identicon": result = contact.identicon
      of "pubKey": result = contact.id
      of "isContact": result = $contact.isContact()
      of "isBlocked": result = $contact.isBlocked()
      of "alias": result = contact.alias
      of "ensVerified": result = $contact.ensVerified
      # TODO check if localNickname exists in the contact ContactsDto
      of "localNickname": result = ""#$contact.localNickname
      of "thumbnailImage": result = $contact.image.thumbnail
      of "largeImage": result = $contact.image.large
      of "requestReceived": result = $contact.requestReceived()

  method data(self: ContactList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.contacts.len:
      return
    let contact = self.contacts[index.row]
    case role.ContactRoles:
      of ContactRoles.Name: result = newQVariant(userNameOrAlias(contact))
      of ContactRoles.Address: result = newQVariant(contact.id)
      of ContactRoles.Identicon: result = newQVariant(contact.identicon)
      of ContactRoles.PubKey: result = newQVariant(contact.id)
      of ContactRoles.IsContact: result = newQVariant(contact.isContact())
      of ContactRoles.IsBlocked: result = newQVariant(contact.isBlocked())
      of ContactRoles.Alias: result = newQVariant(contact.alias)
      of ContactRoles.EnsVerified: result = newQVariant(contact.ensVerified)
      of ContactRoles.LocalNickname: result = newQVariant("")#newQVariant(contact.localNickname)
      of ContactRoles.ThumbnailImage: result = newQVariant(contact.image.thumbnail)
      of ContactRoles.LargeImage: result = newQVariant(contact.image.large)
      of ContactRoles.RequestReceived: result = newQVariant(contact.requestReceived())

  method roleNames(self: ContactList): Table[int, string] =
    {
      ContactRoles.Name.int:"name",
      ContactRoles.Address.int:"address",
      ContactRoles.Identicon.int:"identicon",
      ContactRoles.PubKey.int:"pubKey",
      ContactRoles.IsContact.int:"isContact",
      ContactRoles.IsBlocked.int:"isBlocked",
      ContactRoles.Alias.int:"alias",
      ContactRoles.LocalNickname.int:"localNickname",
      ContactRoles.EnsVerified.int:"ensVerified",
      ContactRoles.ThumbnailImage.int:"thumbnailImage",
      ContactRoles.LargeImage.int:"largeImage",
      ContactRoles.RequestReceived.int:"requestReceived"
    }.toTable

  proc addContactToList*(self: ContactList, contact: ContactsDto) =
    let index = self.getContactIndexByPubkey(contact.id)
    if index > -1:
      return
    self.beginInsertRows(newQModelIndex(), self.contacts.len, self.contacts.len)
    self.contacts.add(contact)
    self.endInsertRows()
    self.countChanged()

  proc removeContactFromList*(self: ContactList, pubkey: string) =
    let index = self.getContactIndexByPubkey(pubkey)
    if index == -1:
      return
    self.beginRemoveRows(newQModelIndex(), index, index)
    self.contacts.delete(index)
    self.endRemoveRows()
    self.countChanged()

  proc hasAddedContacts(self: ContactList): bool {.slot.} = 
    for c in self.contacts:
      if(c.isContact()): return true
    return false

  proc contactChanged*(self: ContactList, pubkey: string) {.signal.}

  proc updateContact*(self: ContactList, contact: ContactsDto) =
    var found = false
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.contacts.len, 0, nil)
    for c in self.contacts.mitems:
      if(c.id != contact.id): continue
      found = true
      c.ensVerified = contact.ensVerified
      c.image = contact.image
      c.added = contact.added
      c.blocked = contact.blocked

    if not found:
      self.addContactToList(contact)
    else:
      self.dataChanged(topLeft, bottomRight, @[ContactRoles.Name.int])
    self.contactChanged(contact.id)

  proc setNewData*(self: ContactList, contactList: seq[ContactsDto]) =
    self.beginResetModel()
    self.contacts = contactList
    self.endResetModel()
    self.countChanged()
