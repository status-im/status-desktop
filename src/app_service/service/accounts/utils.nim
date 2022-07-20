import json
import ../../../backend/accounts as status_account

proc compressPk*(publicKey: string): string =
  try:
    let response = status_account.compressPk(publicKey)
    if(not response.error.isNil):
      echo "error compressPk: " & response.error.message
    result = response.result

  except Exception as e:
    echo "error: `compressPk` " & $e.name & "  msg: " & $e.msg

proc generateAliasFromPk*(publicKey: string): string =
  return status_account.generateAlias(publicKey).result.getStr

proc isAlias*(value: string): bool =
  return status_account.isAlias(value)