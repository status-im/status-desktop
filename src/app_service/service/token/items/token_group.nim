import strutils, sequtils, sugar

import ./token

export token

type TokenGroupItem* = ref object of RootObj
  key*: string
  name*: string
  symbol*: string
  decimals*: int
  logoUri*: string
  tokens*: seq[TokenItem]

proc isCommunityTokenGroup*(self: TokenGroupItem): bool =
  for token in self.tokens:
    if not token.communityData.id.isEmptyOrWhitespace:
      return true
  return false

proc addToken*(self: TokenGroupItem, token: TokenItem) =
  if token.isNil:
    raise newException(ValueError, "token is nil")

  if self.key != token.groupKey:
    raise newException(ValueError, "token group key does not match")

  let tokens = self.tokens.filter(t => cmpIgnoreCase(t.key, token.key) == 0)
  if tokens.len != 0:
    return

  self.tokens.add(token)