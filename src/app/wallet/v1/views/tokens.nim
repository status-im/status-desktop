import strutils, sequtils, json, chronicles, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, json

import status/[status, wallet, tokens, utils]
import ../../../../app_service/[main]
import account_item, accounts, asset_list, token_list

logScope:
  topics = "tokens-view"

QtObject:
  type TokensView* = ref object of QObject
      status: Status
      appService: AppService
      accountsView: AccountsView
      currentAssetList*: AssetList
      defaultTokenList: TokenList
      customTokenList: TokenList

  proc setup(self: TokensView) = self.QObject.setup
  proc delete(self: TokensView) =
    self.currentAssetList.delete
    self.defaultTokenList.delete
    self.customTokenList.delete
    self.QObject.delete

  proc newTokensView*(status: Status, appService: AppService, accountsView: AccountsView): TokensView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.accountsView = accountsView
    result.currentAssetList = newAssetList()
    result.defaultTokenList = newTokenList(status, appService)
    result.customTokenList = newTokenList(status, appService)
    result.setup

  proc hasAsset*(self: TokensView, symbol: string): bool {.slot.} =
    self.status.wallet.hasAsset(symbol)

  proc toggleAsset*(self: TokensView, symbol: string) {.slot.} =
    self.status.wallet.toggleAsset(symbol)
    self.accountsView.setAccountItems()

  proc removeCustomToken*(self: TokensView, tokenAddress: string) {.slot.} =
    let t = self.status.tokens.getCustomTokens().getErc20ContractByAddress(parseAddress(tokenAddress))
    if t == nil: return
    self.status.wallet.hideAsset(t.symbol)
    self.status.tokens.removeCustomToken(tokenAddress)
    self.customTokenList.loadCustomTokens()
    self.accountsView.setAccountItems()

  proc addCustomToken*(self: TokensView, address: string, name: string, symbol: string, decimals: string) {.slot.} =
    self.status.wallet.addCustomToken(symbol, true, address, name, parseInt(decimals), "")

  proc getDefaultTokenList(self: TokensView): QVariant {.slot.} =
    self.defaultTokenList.loadDefaultTokens()
    result = newQVariant(self.defaultTokenList)

  QtProperty[QVariant] defaultTokenList:
    read = getDefaultTokenList

  proc loadCustomTokens(self: TokensView) {.slot.} =
    self.customTokenList.loadCustomTokens()

  proc getCustomTokenList(self: TokensView): QVariant {.slot.} =
    result = newQVariant(self.customTokenList)

  QtProperty[QVariant] customTokenList:
    read = getCustomTokenList

  proc isKnownTokenContract*(self: TokensView, address: string): bool {.slot.} =
    return self.status.wallet.getKnownTokenContract(parseAddress(address)) != nil

  proc decodeTokenApproval*(self: TokensView, tokenAddress: string, data: string): string {.slot.} =
    let amount = data[74..len(data)-1]
    let token = self.status.tokens.getToken(tokenAddress)

    if(token != nil):
      let amountDec = $self.status.wallet.hex2Token(amount, token.decimals)
      return $(%* {"symbol": token.symbol, "amount": amountDec})

    return """{"error":"Unknown token address"}""";

  proc getStatusToken*(self: TokensView): string {.slot.} = self.status.wallet.getStatusToken

  proc currentAssetListChanged*(self: TokensView) {.signal.}

  proc getCurrentAssetList(self: TokensView): QVariant {.slot.} =
    return newQVariant(self.currentAssetList)

  proc setCurrentAssetList*(self: TokensView, assetList: seq[Asset]) =
    self.currentAssetList.setNewData(assetList)
    self.currentAssetListChanged()

  QtProperty[QVariant] assets:
    read = getCurrentAssetList
    write = setCurrentAssetList
    notify = currentAssetListChanged
