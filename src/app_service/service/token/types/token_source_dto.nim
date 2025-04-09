import json_serialization
import token_dto

export token_dto

type TokenSourceDto* = ref object of RootObj
  name* {.serializedFieldName("name").}: string
  tokens* {.serializedFieldName("tokens").}: seq[TokenDto]
  source* {.serializedFieldName("source").}: string
  version* {.serializedFieldName("version").}: string
  lastUpdateTimestamp* {.serializedFieldName("lastUpdateTimestamp").}: int64

type TokenListDto* = ref object of RootObj
    updatedAt* {.serializedFieldName("updatedAt").}: int64
    data* {.serializedFieldName("data").}: seq[TokenSourceDto]