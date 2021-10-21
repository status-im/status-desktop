{.used.}

import json_serialization

import node_config

type
  NetworkDetails* = object
    id*: string
    name*: string
    etherscanLink* {.serializedFieldName("etherscan-link").}: string
    config*: NodeConfig
