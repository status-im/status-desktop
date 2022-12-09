import json, typetraits, tables, sequtils

type
  Fleet* {.pure.} = enum
    Undefined = "",
    Prod = "eth.prod",
    Staging = "eth.staging",
    WakuV2Prod = "wakuv2.prod"
    WakuV2Test = "wakuv2.test"
    GoWakuTest = "go-waku.test"
    StatusTest = "status.test"
    StatusProd = "status.prod"

  FleetNodes* {.pure.} = enum
    Bootnodes = "boot",
    Mailservers = "mail",
    Rendezvous = "rendezvous",
    Whisper = "whisper",
    Waku = "tcp/p2p/waku"
    Websocket = "wss/p2p/waku"

  Meta* = object
    hostname*: string
    timestamp*: uint64

  Conf* = Table[string, Table[string, Table[string, string]]]

type
  FleetConfiguration* = ref object
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
        self.fleet[fleet][nodes][server] = fleetJson["fleets"][fleet][nodes][server].getStr

proc getNodes*(self: FleetConfiguration, fleet: Fleet, nodeType: FleetNodes = FleetNodes.Bootnodes): seq[string] =
  if not self.fleet[$fleet].hasKey($nodeType): return
  result = toSeq(self.fleet[$fleet][$nodeType].values)

proc getMailservers*(self: FleetConfiguration, fleet: Fleet, isWakuV2: bool): Table[string, string] =
  # TODO: If using wakuV2, this assumes that Waku nodes in fleet.status.json are also store nodes.
  # Maybe it make senses to add a "waku-store" section in case we want to have separate node types?
  # Discuss with @iurimatias, @cammellos and Vac team
  let fleetKey = if isWakuV2: $FleetNodes.Waku else: $FleetNodes.Mailservers
  if not self.fleet[$fleet].hasKey(fleetKey) :
    result = initTable[string,string]()
    return
  result = self.fleet[$fleet][fleetKey]
