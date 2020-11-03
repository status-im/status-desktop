import libstatus/core as status
import ../eventemitter
import tables
import json
import libstatus/types

type
  FleetModel* = ref object
    events*: EventEmitter
    config*: FleetConfig

proc newFleetModel*(events: EventEmitter, fleetConfigJson: string): FleetModel =
  result = FleetModel()
  result.events = events
  result.config = fleetConfigJson.toFleetConfig()

proc delete*(self: FleetModel) =
  discard

