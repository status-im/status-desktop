import json, random, times, strutils, os

import signing_phrases

proc generateSigningPhrase*(count: int): string =
  let now = getTime()
  var rng = initRand(now.toUnix * 1000000000 + now.nanosecond)
  var phrases: seq[string] = @[]
  
  for i in 1..count:
    phrases.add(rng.sample(signing_phrases.phrases))

  result = phrases.join(" ")

proc first*(jArray: JsonNode, fieldName, id: string): JsonNode =
  if jArray == nil:
    return nil
  if jArray.kind != JArray:
    raise newException(ValueError, "Parameter 'jArray' is a " & $jArray.kind & ", but must be a JArray")
  for child in jArray.getElems:
    if child{fieldName}.getStr.toLower == id.toLower:
      return child

proc prettyEnsName*(ensName: string): string =
  if ensName.endsWith(".eth"):
    return "@" & ensName.split(".")[0]
  return ensName

const sep = when defined(windows): "\\" else: "/"

proc defaultDataDir(): string =
  let homeDir = getHomeDir()
  let parentDir =
    if defined(development):
      parentDir(getAppDir())
    elif homeDir == "":
      getCurrentDir()
    elif defined(macosx):
      joinPath(homeDir, "Library", "Application Support")
    elif defined(windows):
      let targetDir = getEnv("LOCALAPPDATA").string
      if targetDir == "":
        joinPath(homeDir, "AppData", "Local")
      else:
        targetDir
    else:
      let targetDir = getEnv("XDG_CONFIG_HOME").string
      if targetDir == "":
        joinPath(homeDir, ".config")
      else:
        targetDir
  absolutePath(joinPath(parentDir, "Status"))