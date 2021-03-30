import json
import libstatus/types

type
  FleetModel* = ref object
    config*: FleetConfig

proc newFleetModel*(fleetConfigJson: string): FleetModel =
  result = FleetModel()
  result.config = fleetConfigJson.toFleetConfig()

proc delete*(self: FleetModel) =
  discard

