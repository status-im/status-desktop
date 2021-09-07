{.used.}

import json_serialization

import upstream_config

type
  NodeConfig* = ref object
    networkId* {.serializedFieldName("NetworkId").}: int
    dataDir* {.serializedFieldName("DataDir").}: string
    upstreamConfig* {.serializedFieldName("UpstreamConfig").}: UpstreamConfig