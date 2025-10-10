import json_serialization


type TokenPreferencesDto* = ref object of RootObj
  key* {.serializedFieldName("key").}: string
  position* {.serializedFieldName("position").}: int
  groupPosition* {.serializedFieldName("groupPosition").}: int
  visible* {.serializedFieldName("visible").}: bool
  communityId* {.serializedFieldName("communityId").}: string