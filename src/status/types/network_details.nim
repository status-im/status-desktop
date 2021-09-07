{.used.}

import json_serialization

import node_config

type
  NetworkDetails* = ref object
    id*: string
    name*: string
    etherscanLink* {.serializedFieldName("etherscan-link").}: string
    config*: NodeConfig
