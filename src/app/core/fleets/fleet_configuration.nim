import json, typetraits, tables, sequtils, strutils

type
  Fleet* {.pure.} = enum
    Undefined = ""
    WakuSandbox = "waku.sandbox"
    WakuTest = "waku.test"
    StatusProd = "status.prod"
    StatusStaging = "status.staging"

  FleetNodes* {.pure.} = enum
    Bootnodes = "boot"
    Mailservers = "mail"
    Rendezvous = "rendezvous"
    Whisper = "whisper"
    Waku = "tcp/p2p/waku"
    WakuENR = "enr/p2p/waku"
    WakuBoot = "tcp/p2p/waku/boot"
    WakuBootENR = "enr/p2p/waku/boot"
    WakuStore = "tcp/p2p/waku/store"
    Websocket = "wss/p2p/waku"

  Meta* = object
    hostname*: string
    timestamp*: uint64

  Conf* = Table[string, Table[string, Table[string, string]]]

type FleetConfiguration* = ref object
  fleet: Conf
  meta: Meta

## Forward declaration
proc extractConfig(self: FleetConfiguration, jsonString: string) {.gcsafe.}

proc newFleetConfiguration*(jsonString: string): FleetConfiguration =
  result = FleetConfiguration()
  result.extractConfig(jsonString)

proc delete*(self: FleetConfiguration) =
  discard

proc extractConfig(self: FleetConfiguration, jsonString: string) {.gcsafe.} =
  let fleetJson = jsonString.parseJSON
  self.meta.hostname = fleetJson["meta"]["hostname"].getStr
  self.meta.timestamp = fleetJson["meta"]["timestamp"].getBiggestInt.uint64
  self.fleet = initTable[string, Table[string, Table[string, string]]]()

  for fleet in fleetJson["fleets"].keys():
    self.fleet[fleet] = initTable[string, Table[string, string]]()
    for nodes in fleetJson["fleets"][fleet].keys():
      self.fleet[fleet][nodes] = initTable[string, string]()
      for server in fleetJson["fleets"][fleet][nodes].keys():
        self.fleet[fleet][nodes][server] =
          fleetJson["fleets"][fleet][nodes][server].getStr

proc getNodes*(
    self: FleetConfiguration, fleet: Fleet, nodeType: FleetNodes = FleetNodes.Bootnodes
): seq[string] =
  var t = nodeType
  if fleet == Fleet.StatusProd or fleet == Fleet.StatusStaging:
    case nodeType
    of Bootnodes:
      t = WakuBoot
    of Mailservers:
      t = WakuStore
    of WakuENR:
      t = WakuBootENR
    else:
      discard

  if not self.fleet[$fleet].hasKey($t):
    return
  result = toSeq(self.fleet[$fleet][$t].values)

proc getMailservers*(self: FleetConfiguration, fleet: Fleet): Table[string, string] =
  var fleetKey: string
  if fleet == Fleet.StatusProd or fleet == Fleet.StatusStaging:
    fleetKey = $FleetNodes.WakuStore
  else:
    fleetKey = $FleetNodes.Waku

  if not self.fleet[$fleet].hasKey(fleetKey):
    result = initTable[string, string]()
    return
  result = self.fleet[$fleet][fleetKey]

proc fleetFromString*(fleet: string): Fleet {.inline.} =
  try:
    return parseEnum[Fleet](fleet)
  except:
    return Fleet.Undefined
