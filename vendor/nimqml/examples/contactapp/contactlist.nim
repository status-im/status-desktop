import NimQml, contact, Tables

type
  ContactRoles {.pure.} = enum
    FirstName = UserRole + 1
    Surname = UserRole + 2

QtObject:
  type
    ContactList* = ref object of QAbstractListModel
      contacts*: seq[Contact]

  proc delete(self: ContactList) =
    self.QAbstractListModel.delete
    for contact in self.contacts:
      contact.delete
    self.contacts = @[]

  proc setup(self: ContactList) =
    self.QAbstractListModel.setup

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
    let contactRole = role.ContactRoles
    case contactRole:
    of ContactRoles.FirstName: result = newQVariant(contact.firstName)
    of ContactRoles.Surname: result = newQVariant(contact.surname)

  method roleNames(self: ContactList): Table[int, string] =
    { ContactRoles.FirstName.int:"firstName",
      ContactRoles.Surname.int:"surname"}.toTable

  proc add*(self: ContactList, name: string, surname: string) {.slot.} =
    let contact = newContact()
    contact.firstName = name
    contact.surname = surname
    self.beginInsertRows(newQModelIndex(), self.contacts.len, self.contacts.len)
    self.contacts.add(contact)
    self.endInsertRows()

  proc del*(self: ContactList, pos: int) {.slot.} =
    if pos < 0 or pos >= self.contacts.len:
      return
    self.beginRemoveRows(newQModelIndex(), pos, pos)
    self.contacts.del(pos)
    self.endRemoveRows
