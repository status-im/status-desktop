import json

type Installation* = ref object
  installationId*: string
  name*: string
  deviceType*: string
  enabled*: bool
  isUserDevice*: bool

proc toInstallation*(jsonInstallation: JsonNode): Installation =
  result = Installation(installationid: jsonInstallation{"id"}.getStr, enabled: jsonInstallation{"enabled"}.getBool, name: "", deviceType: "", isUserDevice: false)
  if jsonInstallation["metadata"].kind != JNull:
    result.name = jsonInstallation["metadata"]["name"].getStr
    result.deviceType = jsonInstallation["metadata"]["deviceType"].getStr
