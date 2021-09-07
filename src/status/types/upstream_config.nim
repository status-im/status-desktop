{.used.}

import json_serialization

type
  UpstreamConfig* = ref object
    enabled* {.serializedFieldName("Enabled").}: bool
    url* {.serializedFieldName("URL").}: string