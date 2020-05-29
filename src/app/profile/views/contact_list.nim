import NimQml
import Tables
import strformat
import ../../../status/profile

type
  ContactRoles {.pure.} = enum
    Name = UserRole + 1,
    Address = UserRole + 2

QtObject:
  type ContactList* = ref object of QAbstractListModel
    contacts*: seq[Contact]

  proc setup(self: ContactList) = self.QAbstractListModel.setup

  proc delete(self: ContactList) = self.QAbstractListModel.delete

  proc newContactList*(): ContactList =
    new(result, delete)
    result.contacts = @[]
    result.setup

  method rowCount(self: ContactList, index: QModelIndex = nil): int =
    return self.contacts.len

  method data(self: ContactList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.contacts.len:
      return
    let contact = self.contacts[index.row]
    case role.ContactRoles:
      of ContactRoles.Name: result = newQVariant(contact.name)
      of ContactRoles.Address: result = newQVariant(contact.address)

  method roleNames(self: ContactList): Table[int, string] =
    {
      ContactRoles.Name.int:"name",
      ContactRoles.Address.int:"address",
    }.toTable

  proc addContactToList*(self: ContactList, contact: Contact) =
    self.beginInsertRows(newQModelIndex(), self.contacts.len, self.contacts.len)
    self.contacts.add(contact)
    self.endInsertRows()
