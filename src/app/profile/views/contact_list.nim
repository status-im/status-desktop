import NimQml
import Tables
import strformat
import ../../../status/profile/profile
from ../../../status/ens import nil

type
  ContactRoles {.pure.} = enum
    PubKey = UserRole + 1
    Name = UserRole + 2,
    Address = UserRole + 3
    Identicon = UserRole + 4

QtObject:
  type ContactList* = ref object of QAbstractListModel
    contacts*: seq[Profile]

  proc setup(self: ContactList) = self.QAbstractListModel.setup

  proc delete(self: ContactList) = self.QAbstractListModel.delete

  proc newContactList*(): ContactList =
    new(result, delete)
    # TODO: (rramos) contacts should be a table[string, Profile] instead, with the key being the public key
    # This is to optimize determining if a contact is part of the contact list or not 
    # (including those that do not have a system tag)
    result.contacts = @[]
    result.setup

  method rowCount(self: ContactList, index: QModelIndex = nil): int =
    return self.contacts.len

  proc getUserName(contact: Profile): string =
    if(contact.ensName != "" and contact.ensVerified):
      result = "@" & ens.userName(contact.ensName, true)
    else:
      result = contact.alias

  proc userName(self: ContactList, pubKey: string, defaultValue: string = ""): string {.slot.} =
    for contact in self.contacts:
      if(contact.id != pubKey): continue
      return getUserName(contact)
    return defaultValue

  proc rowData(self: ContactList, index: int, column: string): string {.slot.} =
    let contact = self.contacts[index]
    case column:
      of "name": result = getUserName(contact)
      of "address": result = contact.address
      of "identicon": result = contact.identicon
      of "pubKey": result = contact.id

  method data(self: ContactList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.contacts.len:
      return
    let contact = self.contacts[index.row]
    case role.ContactRoles:
      of ContactRoles.Name: result = newQVariant(getUserName(contact))
      of ContactRoles.Address: result = newQVariant(contact.address)
      of ContactRoles.Identicon: result = newQVariant(contact.identicon)
      of ContactRoles.PubKey: result = newQVariant(contact.id)

  method roleNames(self: ContactList): Table[int, string] =
    {
      ContactRoles.Name.int:"name",
      ContactRoles.Address.int:"address",
      ContactRoles.Identicon.int:"identicon",
      ContactRoles.PubKey.int:"pubKey"
    }.toTable

  proc addContactToList*(self: ContactList, contact: Profile) =
    self.beginInsertRows(newQModelIndex(), self.contacts.len, self.contacts.len)
    self.contacts.add(contact)
    self.endInsertRows()

  proc updateContact*(self: ContactList, contact: Profile) =
    var found = false
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.contacts.len, 0, nil)
    for c in self.contacts:
      if(c.id != contact.id): continue
      found = true
      c.ensName = contact.ensName
      c.ensVerified = contact.ensVerified

    if not found:
      self.addContactToList(contact)
    else:
      self.dataChanged(topLeft, bottomRight, @[ContactRoles.Name.int])
    


