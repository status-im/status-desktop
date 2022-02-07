import json, chronicles, httpclient, net, options
import strutils
import semver

import ../../../backend/ens as status_ens

const APP_UPDATES_ENS* = "desktop.status.eth"
const CHECK_VERSION_TIMEOUT_MS* = 5000

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
