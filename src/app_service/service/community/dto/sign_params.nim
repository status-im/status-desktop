import json

include app_service/common/json_utils

type SignParamsDto* = object
  data*: string
  address*: string
  password*: string

proc toSignParamsDto*(jsonObj: JsonNode): SignParamsDto =
  result = SignParamsDto()
  discard jsonObj.getProp("data", result.data)
  discard jsonObj.getProp("account", result.address)
  discard jsonObj.getProp("password", result.password)

proc toJson*(self: SignParamsDto): JsonNode =
  return %* {
    "data": $self.data,
    "account": $self.address,
    "password": $self.password
  }