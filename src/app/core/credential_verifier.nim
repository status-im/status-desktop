import os, strutils, sequtils

proc runCredentialVerification*(): int =
  echo "Starting credential verification"

  let thingsToCheck = getEnv("THINGS_TO_CHECK")
  if thingsToCheck.len == 0:
    echo "ERROR: THINGS_TO_CHECK environment variable not set"
    return 1

  let credNames = thingsToCheck.splitLines().mapIt(it.strip()).filterIt(it.len > 0)
  if credNames.len == 0:
    echo "ERROR: No credentials to check"
    return 1

  var missingCreds: seq[string] = @[]

  for credName in credNames:
    if not existsEnv(credName):
      missingCreds.add(credName)
      echo "ERROR: Missing environment variable: ", credName

  if missingCreds.len > 0:
    echo "ERROR: Credential verification failed. Missing ", missingCreds.len, " out of ", credNames.len, " credentials"
    return 1
  else:
    echo "SUCCESS: All ", credNames.len, " credentials verified successfully"
    return 0
