from stew/base32 import nil
from stew/base58 import nil
import chronicles, httpclient, net, options
import strutils
import semver

import ../provider/service as provider_service
import ../ens/utils as ens_utils

const APP_UPDATES_ENS* = "desktop.status.eth"
const CHECK_VERSION_TIMEOUT_MS* = 5000

type
  VersionInfo* = object
    version*: string
    url*: string

proc getLatestVersion*(): VersionInfo =
  let contentHash = ens_utils.getContentHash(APP_UPDATES_ENS)
  if contentHash.isNone():
    raise newException(ValueError, "ENS does not have a content hash")

  var url: string = ""

  let decodedHash = ens_utils.decodeENSContentHash(contentHash.get())

  case decodedHash[0]:
    of ENSType.IPFS:
      let
        base58bytes = base58.decode(base58.BTCBase58, decodedHash[1])
        base32Hash = base32.encode(base32.Base32Lower, base58bytes)

      url = "https://" & base32Hash & IPFS_GATEWAY

    of ENSType.SWARM:
      url = "https://" & SWARM_GATEWAY & "/bzz:/" & decodedHash[1]

    of ENSType.IPNS:
      url = "https://" & decodedHash[1]

    else:
      warn "Unknown content for", contentHash
      raise newException(ValueError, "Unknown content for " & contentHash.get())

  # Read version from folder
  let secureSSLContext = newContext()
  let client = newHttpClient(sslContext = secureSSLContext, timeout = CHECK_VERSION_TIMEOUT_MS)
  result.version = client.getContent(url & "/VERSION").strip()
  result.url = url

proc isNewer*(currentVersion, versionToCheck: string): bool =
  let lastVersion = parseVersion(versionToCheck)
  let currVersion = parseVersion(currentVersion)
  result = lastVersion > currVersion
