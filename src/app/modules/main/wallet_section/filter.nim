import strformat, sequtils, sugar

import ./controller
import ./activity/controller as activityc

type Filter* = ref object
  controller: controller.Controller
  activityController: activityc.Controller
  addresses*: seq[string]
  chainIds*: seq[int]
  allAddresses*: bool

proc initFilter*(
  controller: controller.Controller,
  activityController: activityc.Controller
): Filter =
  result = Filter()
  result.controller = controller
  result.activityController = activityController
  result.addresses = @[]
  result.chainIds = @[]
  result.allAddresses = false

proc `$`*(self: Filter): string =
  result = fmt"""WalletFilter(
    addresses: {self.addresses},
    chainIds: {self.chainIds},
    )"""

proc setFillterAllAddresses*(self: Filter) = 
  self.allAddresses = true
  self.addresses = self.controller.getWalletAccounts().map(a => a.address)
  self.activityController.setFilterAddresses(self.addresses)
  self.activityController.updateFilter()

proc toggleWatchOnlyAccounts*(self: Filter) =
  self.controller.toggleIncludeWatchOnlyAccount()

proc includeWatchOnlyToggled*(self: Filter) =
  let includeWatchOnly = self.controller.isIncludeWatchOnlyAccount()
  if includeWatchOnly:
    self.setFillterAllAddresses()
  else:
    self.addresses = self.controller.getWalletAccounts().filter(a => a.walletType != "watch").map(a => a.address)
    self.activityController.setFilterAddresses(self.addresses)
    self.activityController.updateFilter()

proc load*(self: Filter) =
  self.includeWatchOnlyToggled()
  self.chainIds = self.controller.getEnabledChainIds()
  self.activityController.setFilterChains(self.chainIds)
  self.activityController.updateFilter()

proc setAddress*(self: Filter, address: string) =
  self.allAddresses = false
  self.addresses = @[address]
  self.activityController.setFilterAddresses(@[address])
  self.activityController.updateFilter()

proc removeAddress*(self: Filter, address: string) =
  self.allAddresses = false
  if len(self.addresses) == 1 and self.addresses[0] == address:
    let accounts = self.controller.getWalletAccounts()
    self.addresses = @[accounts[0].address]
    return
  
  let ind = self.addresses.find(address)
  if ind > -1:
    self.addresses.delete(ind)
  self.activityController.setFilterAddresses(@[address])
  self.activityController.updateFilter()
  
proc updateNetworks*(self: Filter) =
  self.chainIds = self.controller.getEnabledChainIds()
  self.activityController.setFilterChains(self.chainIds)
  self.activityController.updateFilter()
