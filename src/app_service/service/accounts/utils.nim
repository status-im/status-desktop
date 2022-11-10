import json
import ../../../backend/accounts as status_account
import ../../common/conversion

proc compressPk*(publicKey: string): string =
  try:
    let response = status_account.compressPk(publicKey)
    if(not response.error.isNil):
      echo "error compressPk: " & response.error.message
    result = response.result

  except Exception as e:
    echo "error: `compressPk` " & $e.name & "  msg: " & $e.msg

proc decompressPk*(compressedKey: string): string =
  try:
    let response = status_account.decompressPk(compressedKey)
    if(not response.error.isNil):
      echo "error decompressPk: " & response.error.message
    result = response.result

  except Exception as e:
    echo "error: `decompressPk` " & $e.name & "  msg: " & $e.msg

proc decompressCommunityKey*(publicKey: string): string =
  try:
    let response = status_account.decompressCommunityKey(publicKey)
    if(not response.error.isNil):
      echo "error decompressCommunityKey: " & response.error.message
    result = response.result

  except Exception as e:
    echo "error: `decompressCommunityKey` " & $e.name & "  msg: " & $e.msg

proc compressCommunityKey*(publicKey: string): string =
  try:
    let response = status_account.compressCommunityKey(publicKey)
    if(not response.error.isNil):
      echo "error compressCommunityKey: " & response.error.message
    result = response.result

  except Exception as e:
    echo "error: `compressCommunityKey` " & $e.name & "  msg: " & $e.msg

proc generateAliasFromPk*(publicKey: string): string =
  return status_account.generateAlias(publicKey).result.getStr

proc isAlias*(value: string): bool =
  return status_account.isAlias(value)

# Changes publicKey compression between 33-bytes and multiformat zQ..
proc changeCommunityKeyCompression*(publicKey: string): string =
    if isCompressedPubKey(publicKey):
      # is zQ
      let uncompressedKey = decompressPk(publicKey)
      return compressCommunityKey(uncompressedKey)
    else:
      # is 33-bytes
      let uncompressedKey = decompressCommunityKey(publicKey)
      return compressPk(uncompressedKey)