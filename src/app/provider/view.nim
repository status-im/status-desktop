import NimQml
import status/[status, ens, chat/stickers, wallet, settings, provider]
import status/types/[setting, permission]
import json, json_serialization, sets, strutils
import chronicles
import stew/byteutils

logScope:
  topics = "provider-view"

QtObject:
  type Web3ProviderView* = ref object of QObject
    status*: Status

  proc setup(self: Web3ProviderView) =
    self.QObject.setup

  proc delete*(self: Web3ProviderView) =
    self.QObject.delete

  proc newWeb3ProviderView*(status: Status): Web3ProviderView =
    new(result, delete)
    result = Web3ProviderView()
    result.status = status
    result.setup

  proc disconnect*(self: Web3ProviderView) {.slot.} =
    self.status.permissions.revoke("web3".toPermission())

  proc postMessage*(self: Web3ProviderView, message: string): string {.slot.} =
    result = self.status.provider.postMessage(message)

  proc hasPermission*(self: Web3ProviderView, hostname: string, permission: string): bool {.slot.} =
    result = self.status.permissions.hasPermission(hostname, permission.toPermission())

  proc clearPermissions*(self: Web3ProviderView): string {.slot.} =
    self.status.permissions.clearPermissions()

  proc ensResourceURL*(self: Web3ProviderView, ens: string, url: string): string {.slot.} =
    let (url, base, http_scheme, path_prefix, hasContentHash) = self.status.provider.ensResourceURL(ens, url)
    result = url_replaceHostAndAddPath(url, (if hasContentHash: base else: url_host(base)), http_scheme, path_prefix)

