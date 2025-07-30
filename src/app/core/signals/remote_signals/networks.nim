import json, json_serialization
import base

import backend/provider_status_types

type NetworksBlockchainHealthChangedSignal* = ref object of Signal
  fullStatus*: BlockchainFullStatus

proc fromEvent*(T: type NetworksBlockchainHealthChangedSignal, event: JsonNode): NetworksBlockchainHealthChangedSignal =
  result = NetworksBlockchainHealthChangedSignal()
  result.signalType = SignalType.NetworksBlockchainHealthChanged
  result.fullStatus = BlockchainFullStatus.fromJson(event["event"])