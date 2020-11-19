import NimQml, tables
import ../../../status/profile/profile

type
  SuggestionRoles {.pure.} = enum
    Alias = UserRole + 1,
    Identicon = UserRole + 2,
    Address = UserRole + 3,
    EnsName = UserRole + 4,
    EnsVerified = UserRole + 5
    LocalNickname = UserRole + 6

QtObject:
  type SuggestionsList* = ref object of QAbstractListModel
    suggestions*: seq[Profile]

  proc setup(self: SuggestionsList) = self.QAbstractListModel.setup

  proc delete(self: SuggestionsList) =
    self.suggestions = @[]
    self.QAbstractListModel.delete

  proc newSuggestionsList*(): SuggestionsList =
    new(result, delete)
    result.suggestions = @[]
    result.setup

  proc rowData(self: SuggestionsList, index: int, column: string): string {.slot.} =
    if (index >= self.suggestions.len):
      return
    let suggestion = self.suggestions[index]
    case column:
      of "alias": result = suggestion.alias
      of "ensName": result = suggestion.ensName
      of "address": result = suggestion.address
      of "identicon": result = suggestion.identicon
      of "localNickname": result = suggestion.localNickname

  method rowCount(self: SuggestionsList, index: QModelIndex = nil): int =
    return self.suggestions.len

  method data(self: SuggestionsList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.suggestions.len:
      return
    let suggestion = self.suggestions[index.row]
    let suggestionRole = role.SuggestionRoles
    case suggestionRole:
    of SuggestionRoles.Alias: result = newQVariant(suggestion.alias)
    of SuggestionRoles.Identicon: result = newQVariant(suggestion.identicon)
    of SuggestionRoles.Address: result = newQVariant(suggestion.address)
    of SuggestionRoles.EnsName: result = newQVariant(suggestion.ensName)
    of SuggestionRoles.EnsVerified: result = newQVariant(suggestion.ensVerified)
    of SuggestionRoles.LocalNickname: result = newQVariant(suggestion.localNickname)

  method roleNames(self: SuggestionsList): Table[int, string] =
    { SuggestionRoles.Alias.int:"alias",
    SuggestionRoles.Identicon.int:"identicon",
    SuggestionRoles.Address.int:"address",
    SuggestionRoles.EnsName.int:"ensName",
    SuggestionRoles.LocalNickname.int:"localNickname",
    SuggestionRoles.EnsVerified.int:"ensVerified" }.toTable

  proc addSuggestionToList*(self: SuggestionsList, profile: Profile) =
    self.beginInsertRows(newQModelIndex(), self.suggestions.len, self.suggestions.len)
    self.suggestions.add(profile)
    self.endInsertRows()

  proc setNewData*(self: SuggestionsList, suggestionsList: seq[Profile]) =
    self.beginResetModel()
    self.suggestions = suggestionsList
    self.endResetModel()

  proc forceUpdate*(self: SuggestionsList) =
    self.beginResetModel()
    self.endResetModel()
