import strformat, sequtils, sugar

import ./controller

type Filter* = ref object
  controller: controller.Controller
  addresses*: seq[string]
  chainIds*: seq[int]
  allChainsEnabled*: bool
  allAddresses*: bool

proc initFilter*(
  controller: controller.Controller
): Filter =
  result = Filter()
  result.controller = controller
  result.addresses = @[]
  result.chainIds = @[]
  result.allChainsEnabled = true
  result.allAddresses = false

proc `$`*(self: Filter): string =
  result = fmt"""WalletFilter(
    addresses: {self.addresses},
    chainIds: {self.chainIds},
    )"""

proc setFillterAllAddresses*(self: Filter) = 
  self.allAddresses = true

  self.addresses = self.controller.getWalletAccounts().filter(a => not a.hideFromTotalBalance).map(a => a.address)

proc setAddress*(self: Filter, address: string) =
  self.allAddresses = false
  self.addresses = @[address]

proc removeAddress*(self: Filter, address: string) =
  if len(self.addresses) == 1 and self.addresses[0] == address:
    let accounts = self.controller.getWalletAccounts()
    self.addresses = @[accounts[0].address]
    return

  let ind = self.addresses.find(address)
  if ind > -1:
    self.addresses.delete(ind)

proc updateNetworks*(self: Filter) =
  self.chainIds = self.controller.getEnabledChainIds()
  self.allChainsEnabled = (self.chainIds.len == self.controller.getNetworks().len)

proc load*(self: Filter) =
  self.setFillterAllAddresses()
  self.updateNetworks()
