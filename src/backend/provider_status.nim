import provider_status_types
export provider_status_types

import json
import ./core, ./response_type
from ./gen import rpc

rpc(getBlockchainHealthStatus, "wallet"):
  discard


