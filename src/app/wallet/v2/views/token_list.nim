import # nim libs
  tables, json

import # vendor libs
  NimQml, web3/ethtypes
from web3/conversions import `$`

import # status-desktop libs
  status/eth/contracts

type
  TokenRoles {.pure.} = enum
    Name = UserRole + 1,
    Symbol = UserRole + 2,
    HasIcon = UserRole + 3,
    Address = UserRole + 4,
    Decimals = UserRole + 5
    IsCustom = UserRole + 6

QtObject:
  type TokenList* = ref object of QAbstractListModel
    tokens*: seq[Erc20Contract]
    isCustom*: bool

  proc setup(self: TokenList) = 
    self.QAbstractListModel.setup

  proc delete(self: TokenList) =
    self.tokens = @[]
    self.QAbstractListModel.delete

  proc newTokenList*(): TokenList =
    new(result, delete)
    result.tokens = @[]
    result.setup

  proc rowData(self: TokenList, index: int, column: string): string {.slot.} =
    if (index >= self.tokens.len):
      return
    let token = self.tokens[index]
    case column:
      of "name": result = token.name
      of "symbol": result = token.symbol
      of "hasIcon": result = $token.hasIcon
      of "address": result = $token.address
      of "decimals": result = $token.decimals

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
    of TokenRoles.Name: result = newQVariant(token.name)
    of TokenRoles.Symbol: result = newQVariant(token.symbol)
    of TokenRoles.HasIcon: result = newQVariant(token.hasIcon)
    of TokenRoles.Address: result = newQVariant($token.address)
    of TokenRoles.Decimals: result = newQVariant(token.decimals)
    of TokenRoles.IsCustom: result = newQVariant(self.isCustom)

  method roleNames(self: TokenList): Table[int, string] =
    {TokenRoles.Name.int:"name",
    TokenRoles.Symbol.int:"symbol",
    TokenRoles.HasIcon.int:"hasIcon",
    TokenRoles.Address.int:"address",
    TokenRoles.Decimals.int:"decimals",
    TokenRoles.IsCustom.int:"isCustom"}.toTable