import json

include app_service/common/json_utils

# kv_store keys:
const RLN_RATE_LIMIT_ENABLED* = "rlnRateLimitEnabled"

type
  KvstoreDto* = object
    rlnRateLimitEnabled*: bool

proc toKvstoreDto*(jsonObj: JsonNode): KvstoreDto =
  discard jsonObj.getProp(RLN_RATE_LIMIT_ENABLED, result.rlnRateLimitEnabled)
