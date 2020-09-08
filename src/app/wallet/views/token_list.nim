import NimQml, tables, json
import ../../../status/libstatus/default_tokens
import ../../../status/libstatus/tokens

type
  TokenRoles {.pure.} = enum
    Name = UserRole + 1,
    Symbol = UserRole + 2,
    HasIcon = UserRole + 3,
    Address = UserRole + 4

QtObject:
  type TokenList* = ref object of QAbstractListModel
    tokens*: seq[JsonNode]

  proc setup(self: TokenList) = 
    self.QAbstractListModel.setup

  proc delete(self: TokenList) =
    self.tokens = @[]
    self.QAbstractListModel.delete

  proc tokensLoaded(self: TokenList, cnt: int) {.signal.} 

  proc loadDefaultTokens*(self:TokenList) = 
    if self.tokens.len == 0:
      self.tokens = getDefaultTokens().getElems()
      self.tokensLoaded(self.tokens.len)

  proc loadCustomTokens*(self: TokenList) =
    self.beginResetModel()
    self.tokens = getCustomTokens().getElems()
    self.tokensLoaded(self.tokens.len)
    self.endResetModel()

  proc newTokenList*(): TokenList =
    new(result, delete)
    result.tokens = @[]
    result.setup

  method rowCount(self: TokenList, index: QModelIndex = nil): int =
    return self.tokens.len

  method data(self: TokenList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.tokens.len:
      return
    let token = self.tokens[index.row]
    let tokenRole = role.TokenRoles
    case tokenRole:
    of TokenRoles.Name: result = newQVariant(token["name"].getStr)
    of TokenRoles.Symbol: result = newQVariant(token["symbol"].getStr)
    of TokenRoles.HasIcon: result = newQVariant(token{"hasIcon"}.getBool)
    of TokenRoles.Address: result = newQVariant(token["address"].getStr)

  method roleNames(self: TokenList): Table[int, string] =
    {TokenRoles.Name.int:"name",
    TokenRoles.Symbol.int:"symbol",
    TokenRoles.HasIcon.int:"hasIcon",
    TokenRoles.Address.int:"address"}.toTable

