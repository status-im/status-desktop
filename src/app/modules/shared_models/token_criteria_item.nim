import strformat

type
  TokenCriteriaItem* = object
    symbol*: string
    name*: string
    amount*: string
    `type`*: int
    ensPattern*: string
    criteriaMet*: bool

proc initTokenCriteriaItem*(
  symbol: string,
  name: string,
  amount: string,
  `type`: int,
  ensPattern: string,
  criteriaMet: bool
): TokenCriteriaItem =
  result.symbol = symbol
  result.name = name
  result.`type` = `type`
  result.ensPattern = ensPattern
  result.amount = amount
  result.criteriaMet = criteriaMet

proc `$`*(self: TokenCriteriaItem): string =
  result = fmt"""TokenCriteriaItem(
    symbol: {self.symbol},
    name: {self.name},
    amount: {self.amount},
    type: {self.type},
    ensPattern: {self.ensPattern},
    criteriaMet: {self.criteriaMet}
    ]"""

proc getType*(self: TokenCriteriaItem): int =
  return self.`type`

proc getSymbol*(self: TokenCriteriaItem): string =
  return self.symbol

proc getName*(self: TokenCriteriaItem): string =
  return self.name

proc getAmount*(self: TokenCriteriaItem): string =
  return self.amount

proc getEnsPattern*(self: TokenCriteriaItem): string =
  return self.ensPattern

proc getCriteriaMet*(self: TokenCriteriaItem): bool =
  return self.criteriaMet
