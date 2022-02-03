import stew/byteutils
from stew/base32 import nil
from stew/base58 import nil
import ./statusgo_backend_new/ens as status_ens 
import chronicles, httpclient, net
import strutils
import json
import semver
import constants


type
  VersionInfo* = object
    version*: string
    url*: string

proc getLatestVersion*(): VersionInfo =
  let response = status_ens.resourceUrl(chainId=1, username=APP_UPDATES_ENS)
  let host = response.result{"Host"}.getStr
  if host == "":
    raise newException(ValueError, "ENS does not have a content hash")

  let url = "https://" & host & response.result{"Path"}.getStr

  # Read version from folder
  let secureSSLContext = newContext()
  let client = newHttpClient(sslContext = secureSSLContext, timeout = CHECK_VERSION_TIMEOUT_MS)
  result.version = client.getContent(url & "/VERSION").strip()
  result.url = url

proc isNewer*(currentVersion, versionToCheck: string): bool =
  let lastVersion = parseVersion(versionToCheck)
  let currVersion = parseVersion(currentVersion)
  result = lastVersion > currVersion
