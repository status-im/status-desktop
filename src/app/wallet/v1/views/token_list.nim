import # nim libs
  strformat, tables, json

import # vendor libs
  NimQml

import # status-desktop libs
  status/[utils, tokens, settings],
  status/types/network_type,
  status/status
import ../../../../app_service/[main]
import ../../../../app_service/tasks/[qt, threadpool]
import ../../../../app_service/tasks/marathon/mailserver/worker
from web3/conversions import `$`

type
  TokenRoles {.pure.} = enum
    Name = UserRole + 1,
    Symbol = UserRole + 2,
    HasIcon = UserRole + 3,
    Address = UserRole + 4,
    Decimals = UserRole + 5
    IsCustom = UserRole + 6

  GetTokenDetailsTaskArg = ref object of QObjectTaskArg
    chainId: int
    address: string

const getTokenDetailsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetTokenDetailsTaskArg](argEncoded)
  try:
    let 
      tkn = newErc20Contract(arg.chainId, arg.address.parseAddress)
      decimals = tkn.tokenDecimals()
      output = %* {
        "address": arg.address,
        "name": tkn.tokenName(),
        "symbol": tkn.tokenSymbol(),
        "decimals": (if decimals == 0: "" else: $decimals)
      }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "address": arg.address,
      "error": fmt"{e.msg}. Is this an ERC-20 or ERC-721 contract?",
    }
    arg.finish(output)

proc getTokenDetails[T](self: T, slot: string, chainId: int, address: string) =
  let arg = GetTokenDetailsTaskArg(
    tptr: cast[ByteAddress](getTokenDetailsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    chainId: chainId,
    address: address)
  self.appService.threadpool.start(arg)

QtObject:
  type TokenList* = ref object of QAbstractListModel
    status: Status
    appService: AppService
    tokens*: seq[Erc20Contract]
    isCustom*: bool

  proc setup(self: TokenList) = 
    self.QAbstractListModel.setup

  proc delete(self: TokenList) =
    self.tokens = @[]
    self.QAbstractListModel.delete

  proc tokensLoaded(self: TokenList, cnt: int) {.signal.} 

  proc loadDefaultTokens*(self:TokenList) = 
    if self.tokens.len == 0:
      let chainId = self.status.settings.getCurrentNetwork().toChainId()
      self.tokens = allErc20ContractsByChainId(chainId)
      self.isCustom = false
      self.tokensLoaded(self.tokens.len)

  proc loadCustomTokens*(self: TokenList) =
    self.beginResetModel()
    self.tokens = self.status.tokens.getCustomTokens()
    self.tokensLoaded(self.tokens.len)
    self.isCustom = true
    self.endResetModel()

  proc newTokenList*(status: Status, appService: AppService): TokenList =
    new(result, delete)
    result.tokens = @[]
    result.status = status
    result.appService = appService
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

  proc getTokenDetails*(self: TokenList, address: string) {.slot.} =
    let chainId = self.status.settings.getCurrentNetwork().toChainId()
    self.getTokenDetails("tokenDetailsResolved", chainId, address)

  proc tokenDetailsWereResolved*(self: TokenList, tokenDetails: string) {.signal.}

  proc tokenDetailsResolved(self: TokenList, tokenDetails: string) {.slot.} =
    self.tokenDetailsWereResolved(tokenDetails)
