import strutils

import ./dto

proc flatModelKey*(self: TokenDto): string =
  result = $self.chainID & self.address

proc bySymbolModelKey*(self: TokenDto): string =
  if self.communityData.id.isEmptyOrWhitespace:
    result = self.symbol
  else:
    result = self.address
