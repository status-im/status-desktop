import stint, json, strutils, chronicles

include app_service/common/json_utils

proc hexToDec*(hex: string): string =
  return stint.parse(hex, UInt256, 16).toString()

proc getFloatFromJson(jsonObj: JsonNode, key: string): float =
  if jsonObj.contains(key):
    case jsonObj[key].kind
    of JFloat:
      result = jsonObj[key].getFloat
    of JString:
      result = parseFloat(jsonObj[key].getStr)
    of JInt:
      result = float(jsonObj[key].getInt)
    else:
      raise newException(CatchableError, "cannot resolve value for key: " & key)

proc convertFeesInfoToHex*(feesInfoJson: string): string =
  try:
    if feesInfoJson.len == 0:
      raise newException(CatchableError, "feesInfoJson is empty")

    let
      parsedJson = parseJson(feesInfoJson)

      maxFeePerGasFloat = getFloatFromJson(parsedJson, "maxFeePerGas")
      maxFeePerGasWei = uint64(maxFeePerGasFloat * 1e9)

      maxPriorityFeePerGasFloat = getFloatFromJson(parsedJson, "maxPriorityFeePerGas")
      maxPriorityFeePerGasWei = uint64(maxPriorityFeePerGasFloat * 1e9)

    # Assemble the JSON and return it
    var resultJson =
      %*{
        "maxFeePerGas":
          "0x" & toHex(maxFeePerGasWei).strip(chars = {'0'}, trailing = false),
        "maxPriorityFeePerGas":
          "0x" & toHex(maxPriorityFeePerGasWei).strip(chars = {'0'}, trailing = false),
      }
    return $resultJson
  except Exception as e:
    error "cannot convert fees info to hex: ", msg = e.msg
