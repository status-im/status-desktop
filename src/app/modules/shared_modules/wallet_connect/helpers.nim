import stint, json, strutils

proc hexToDec*(hex: string): string =
  return stint.parse(hex, UInt256, 16).toString()

proc convertFeesInfoToHex*(feesInfoJson: string): string =
  let parsedJson = parseJson(feesInfoJson)

  let maxFeeFloat = parsedJson["maxFeePerGas"].getFloat()
  let maxFeeWei = int64(maxFeeFloat * 1e9)

  let maxPriorityFeeFloat = parsedJson["maxPriorityFeePerGas"].getFloat()
  let maxPriorityFeeWei = int64(maxPriorityFeeFloat * 1e9)

  # Assemble the JSON and return it
  var resultJson = %* {
    "maxFeePerGas": "0x" & toHex(maxFeeWei).strip(chars = {'0'}, trailing = false),
    "maxPriorityFeePerGas": "0x" & toHex(maxPriorityFeeWei).strip(chars = {'0'}, trailing = false)
  }
  return $resultJson

