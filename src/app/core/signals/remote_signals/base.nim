import app_service/common/safe_json_serialization
import signal_type

import ../../eventemitter

export signal_type

type Signal* = ref object of Args
  signalType* {.serializedFieldName("type").}: SignalType
  signalTypeStr*: string
