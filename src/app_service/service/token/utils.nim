import strutils

import ./dto

proc tokenKey*(self: TokenDto): string =
  result = $self.chainID & self.address

proc byNameModelKey*(self: TokenDto): string =
  if self.communityData.id.isEmptyOrWhitespace:
    let compressedName = self.name.replace(" ", "") # case sensitive covers case like "USDCoin" and "USD Coin", but not "Aave Interest bearing SNX" and "Aave interest bearing SNX"
    return compressedName
  else:
    return self.address
  return "-"
