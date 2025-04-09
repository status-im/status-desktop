import json, times, stint, strutils, sugar, os, re, chronicles

import nimcrypto, std/strformat
import account_constants

import ../../constants as main_constants

const STATUS_DOMAIN* = ".stateofus.eth"
const ETH_DOMAIN* = ".eth"

proc makeTokenKey*(chainId: int, address: string): string =
  return fmt"{chainID}-{address}"

proc arrayContains*[T](arr: seq[T], value: T): bool =
  return arr.any(x => x == value)

proc hashPassword*(password: string, lower: bool = true): string =
  let hashed = "0x" & $keccak_256.digest(password)

  if lower:
    return hashed.toLowerAscii()

  return hashed

proc hashedPasswordToUpperCase*(hashedPassword: string): string =
  return "0x" & hashedPassword[2 .. ^1].toUpperAscii()

proc prefix*(methodName: string, isExt:bool = true): string =
  result = "waku"
  result = result & (if isExt: "ext_" else: "_")
  result = result & methodName

proc first*(jArray: JsonNode, fieldName, id: string): JsonNode =
  if jArray == nil:
    return nil
  if jArray.kind != JArray:
    raise newException(ValueError, "Parameter 'jArray' is a " & $jArray.kind & ", but must be a JArray")
  for child in jArray.getElems:
    if child{fieldName}.getStr.toLower == id.toLower:
      return child

const sep = when defined(windows): "\\" else: "/"

proc defaultDataDir(): string =
  let homeDir = getHomeDir()
  let parentDir =
    if defined(development):
      parentDir(getAppDir())
    elif homeDir == "":
      getCurrentDir()
    elif main_constants.IS_MACOS:
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

proc validateLink*(link: string): bool =
  result = true
  if link.len() != 0:
    if not match(
        link, re"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)", 0):
      error "Invalid social link", errDescription = link
      result = false

proc isPathOutOfTheDefaultStatusDerivationTree*(path: string): bool =
  if not path.startsWith(account_constants.PATH_WALLET_ROOT&"/") or
    path.count("'") != 3 or
    path.count("/") != 5:
      return true
  return false

proc contractUniqueKey*(chainId: int, contractAddress: string): string =
  return $chainId & "_" & contractAddress

proc intersectSeqs*[T](seq1, seq2: seq[T]): seq[T] =
  for item in seq1:
    if item in seq2:
      result.add(item)

proc stringToUint256*(value: string): Uint256 =
  var parsedValue = stint.u256(0)
  try:
    parsedValue = value.parse(Uint256)
  except Exception as e:
    discard
  return parsedValue

proc createHash*(signature: string): string =
  let signatureHex = if signature.startsWith("0x"): signature[2..^1] else: signature

  return hashPassword(signatureHex, true)