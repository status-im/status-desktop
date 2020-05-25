import NimQml
import Tables

type
  MailserverRoles {.pure.} = enum
    Name = UserRole + 1,
    Endpoint = UserRole + 2

type
  MailServer* = ref object of QObject
    name*, endpoint*: string

QtObject:
  type MailServersList* = ref object of QAbstractListModel
    mailservers*: seq[MailServer]

  proc setup(self: MailServersList) = self.QAbstractListModel.setup

  proc delete(self: MailServersList) = self.QAbstractListModel.delete

  proc newMailServersList*(): MailServersList =
    new(result, delete)
    result.mailservers = @[]
    result.setup

  method rowCount(self: MailServersList, index: QModelIndex = nil): int =
    return self.mailservers.len

  method data(self: MailServersList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.mailservers.len:
      return
    let mailserver = self.mailservers[index.row]
    case role.MailServerRoles:
      of MailServerRoles.Name: result = newQVariant(mailserver.name)
      of MailServerRoles.Endpoint: result = newQVariant(mailserver.endpoint)

  method roleNames(self: MailServersList): Table[int, string] =
    {
      MailServerRoles.Name.int:"name",
      MailServerRoles.Endpoint.int:"endpoint",
    }.toTable

  proc add*(self: MailServersList, name: string, endpoint: string) {.slot.} =
    self.beginInsertRows(newQModelIndex(), self.mailservers.len, self.mailservers.len)
    self.mailservers.add(MailServer(name: name,
                                    endpoint: endpoint))
    self.endInsertRows()

