import json
import json_serialization
import signal_type

import eventemitter

export signal_type

type Signal* = ref object of Args
  signalType* {.serializedFieldName("type").}: SignalType
  signalTypeStr*: string

type SignalError* = object
  error*: string

type NodeSignal* = ref object of Signal
  event*: SignalError
