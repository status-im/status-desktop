import strformat

import ./controller


type Filter* = ref object
  controller: Controller
  addresses*: seq[string]
  chainIds*: seq[int]

proc initFilter*(
  controller: Controller,
): Filter =
  result = Filter()
  result.controller = controller
  result.addresses = @[]
  result.chainIds = @[]


proc `$`*(self: Filter): string =
  result = fmt"""WalletFilter(
    addresses: {self.addresses},
    chainIds: {self.chainIds},
    )"""


proc load*(self: Filter) =
  let accounts = self.controller.getWalletAccounts()
  self.addresses = @[accounts[0].address]
  self.chainIds = self.controller.getEnabledChainIds()

proc setAddress*(self: Filter, address: string) = 
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