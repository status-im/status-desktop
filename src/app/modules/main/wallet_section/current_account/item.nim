import strformat

type 
  Item* = object
    etherscanLink: string
    signingPhrase: string

proc initItem*(etherscanLink: string, signingPhrase: string): Item =
  result.etherscanLink = etherscanLink
  result.signingPhrase = signingPhrase

proc `$`*(self: Item): string =
  result = fmt"""MainAccountItem(
    etherscanLink: {self.etherscanLink}, 
    signingPhrase: {self.signingPhrase}
    ]"""

proc getEtherscanLink*(self: Item): string = 
  return self.etherscanLink

proc getSigningPhrase*(self: Item): string = 
  return self.signingPhrase