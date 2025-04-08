import json

include app_service/common/json_utils

# kv_store keys:
const CONFIG_RLN_RATE_LIMIT_ENABLED* = "config/rln-rate-limit-enabled"

type
  KvstoreDto* = object
    rlnRateLimitEnabled*: bool

proc toKvstoreDto*(jsonObj: JsonNode): KvstoreDto =
  discard jsonObj.getProp(CONFIG_RLN_RATE_LIMIT_ENABLED, result.rlnRateLimitEnabled)
