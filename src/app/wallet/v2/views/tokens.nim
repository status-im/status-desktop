import NimQml, chronicles
import status/[status]
import token_list

logScope:
  topics = "tokens-view"

QtObject:
  type TokensView* = ref object of QObject
      status: Status
      tokenList: TokenList
      customTokenList: TokenList

  proc setup(self: TokensView) = self.QObject.setup
  proc delete(self: TokensView) =
    self.tokenList.delete
    self.customTokenList.delete
    self.QObject.delete

  proc newTokensView*(status: Status): TokensView =
    new(result, delete)
    result.status = status
    result.tokenList = newTokenList()
    result.customTokenList = newTokenList()
    result.setup

  QtProperty[QVariant] tokenList:
    read = getTokenList

  proc getCustomTokenList(self: TokensView): QVariant {.slot.} =
    result = newQVariant(self.customTokenList)

  QtProperty[QVariant] customTokenList:
    read = getCustomTokenList