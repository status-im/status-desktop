import NimQml, stew/shims/strformat, stint

import ./gas_estimate_item, ./suggested_route_model, ./network_model

QtObject:
  type TransactionRoutes* = ref object of QObject
    suggestedRoutes: SuggestedRouteModel
    gasTimeEstimate: GasEstimateItem
    amountToReceive: UInt256
    toNetworksModel: NetworkModel
    rawPaths: string

  proc setup*(self: TransactionRoutes,
    suggestedRoutes: SuggestedRouteModel,
    gasTimeEstimate: GasEstimateItem,
    amountToReceive: UInt256,
    toNetworksModel: NetworkModel,
    rawPaths: string
    ) =
      self.QObject.setup
      self.suggestedRoutes = suggestedRoutes
      self.gasTimeEstimate = gasTimeEstimate
      self.amountToReceive = amountToReceive
      self.toNetworksModel = toNetworksModel
      self.rawPaths = rawPaths

  proc delete*(self: TransactionRoutes) =
      self.QObject.delete

  proc newTransactionRoutes*(
    suggestedRoutes: SuggestedRouteModel = newSuggestedRouteModel(),
    gasTimeEstimate: GasEstimateItem = newGasEstimateItem(),
    amountToReceive: UInt256 = stint.u256(0),
    toNetworksModel: NetworkModel = newNetworkModel(),
    rawPaths: string = ""
    ): TransactionRoutes =
    new(result, delete)
    result.setup(suggestedRoutes, gasTimeEstimate, amountToReceive, toNetworksModel, rawPaths)

  proc `$`*(self: TransactionRoutes): string =
    result = fmt"""TransactionRoutes(
      suggestedRoutes: {self.suggestedRoutes},
      gasTimeEstimate: {self.gasTimeEstimate},
      amountToReceive: {self.amountToReceive},
      toNetworksModel: {self.toNetworksModel},
      rawPaths: {self.rawPaths},
      ]"""

  proc suggestedRoutesChanged*(self: TransactionRoutes) {.signal.}
  proc getSuggestedRoutes*(self: TransactionRoutes): QVariant {.slot.} =
    return newQVariant(self.suggestedRoutes)
  QtProperty[QVariant] suggestedRoutes:
    read = getSuggestedRoutes
    notify = suggestedRoutesChanged

  proc gasTimeEstimateChanged*(self: TransactionRoutes) {.signal.}
  proc getGasTimeEstimate*(self: TransactionRoutes): QVariant {.slot.} =
    return newQVariant(self.gasTimeEstimate)
  QtProperty[QVariant] gasTimeEstimate:
    read = getGasTimeEstimate
    notify = gasTimeEstimateChanged

  proc amountToReceiveChanged*(self: TransactionRoutes) {.signal.}
  proc getAmountToReceive*(self: TransactionRoutes): string {.slot.} =
    return self.amountToReceive.toString()
  QtProperty[string] amountToReceive:
    read = getAmountToReceive
    notify = amountToReceiveChanged

  proc toNetworksChanged*(self: TransactionRoutes) {.signal.}
  proc getToNetworks*(self: TransactionRoutes): QVariant {.slot.} =
    return newQVariant(self.toNetworksModel)
  QtProperty[QVariant] toNetworksModel:
    read = getToNetworks
    notify = toNetworksChanged

  proc rawPathsChanged*(self: TransactionRoutes) {.signal.}
  proc getRawPaths*(self: TransactionRoutes): string {.slot.} =
    return self.rawPaths
  QtProperty[string] rawPaths:
    read = getRawPaths
    notify = rawPathsChanged
