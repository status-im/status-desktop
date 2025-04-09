import app_service/common/types as common_types

type TokenListItem* = ref object of RootObj
    name*: string
    updatedAt* : int64
    source*: string
    version*: string
    tokensCount*: int

type
  TokenItem* = ref object of RootObj
    key*: string # key is created using chainId and address and uniquely identifies a token
    groupKey*: string # groupKey is created using tokenId and defines a group this token belongs to
    name*: string
    symbol*: string
    sources*: seq[string]
    chainID*: int
    address*: string
    decimals*: int
    image*: string # will remain empty until backend provides us this data
    `type`*: common_types.TokenType
    communityId*: string

type
  TokenGroupItem* = ref object of RootObj
    key*: string # key uniquely identifies a group
    name*: string
    symbol*: string
    image*: string
    decimals*: int
    `type`*: common_types.TokenType
    tokens*: seq[TokenItem]


proc cmpTokenItem*(x, y: TokenItem): int =
    cmp(x.name, y.name)

proc cmpTokenGroupItem*(x, y: TokenGroupItem): int =
    cmp(x.name, y.name)

proc containsTokenItemByKey*(self: TokenGroupItem, tokenKey: string): bool =
  for t in self.tokens:
      if t.key == tokenKey:
          return true
  return false

proc containsTokenItem*(self: TokenGroupItem, token: TokenItem): bool =
  return self.containsTokenItemByKey(token.key)

