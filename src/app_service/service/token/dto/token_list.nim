import json_serialization

import ./token as token_dto

export token_dto


type VersionDto* = object
  major* {.serializedFieldName("major").}: int
  minor* {.serializedFieldName("minor").}: int
  patch* {.serializedFieldName("patch").}: int

type TokenListDto* = ref object of RootObj
  id* {.serializedFieldName("id").}: string
  name* {.serializedFieldName("name").}: string
  timestamp* {.serializedFieldName("timestamp").}: string
  fetchedTimestamp* {.serializedFieldName("fetchedTimestamp").}: string
  source* {.serializedFieldName("source").}: string
  version* {.serializedFieldName("version").}: VersionDto
  logoUri* {.serializedFieldName("logoUri").}: string
  tokens* {.serializedFieldName("tokens").}: seq[TokenDtoSafe]