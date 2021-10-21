import json_serialization

type
  UpstreamConfig* = object
    enabled* {.serializedFieldName("Enabled").}: bool
    url* {.serializedFieldName("URL").}: string