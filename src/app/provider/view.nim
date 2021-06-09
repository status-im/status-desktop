import NimQml
import ../../status/[status, ens, chat/stickers, wallet, settings, provider]
import ../../status/types
import json, json_serialization, sets, strutils
import chronicles
import nbaser
import stew/byteutils
from base32 import nil

logScope:
  topics = "provider-view"

QtObject:
  type Web3ProviderView* = ref object of QObject
    status*: Status
    dappsAddress*: string

  proc setup(self: Web3ProviderView) =
    self.QObject.setup

  proc delete*(self: Web3ProviderView) =
    self.QObject.delete

  proc newWeb3ProviderView*(status: Status): Web3ProviderView =
    new(result, delete)
    result = Web3ProviderView()
    result.status = status
    result.dappsAddress = ""
    result.setup

  proc hasPermission*(self: Web3ProviderView, hostname: string, permission: string): bool {.slot.} =
    result = self.status.permissions.hasPermission(hostname, permission.toPermission())

  proc disconnect*(self: Web3ProviderView) {.slot.} =
    self.status.permissions.revoke("web3".toPermission())

  proc postMessage*(self: Web3ProviderView, message: string): string {.slot.} =
    result = self.status.provider.postMessage(message)

  proc getNetworkId*(self: Web3ProviderView): int {.slot.} =
    self.status.settings.getCurrentNetworkDetails().config.networkId

  QtProperty[int] networkId:
    read = getNetworkId

  proc dappsAddressChanged(self: Web3ProviderView, address: string) {.signal.}

  proc getDappsAddress(self: Web3ProviderView): string {.slot.} =
    result = self.dappsAddress

  proc setDappsAddress(self: Web3ProviderView, address: string) {.slot.} =
    self.dappsAddress = address
    self.status.saveSetting(Setting.DappsAddress, address)
    self.dappsAddressChanged(address)

  QtProperty[string] dappsAddress:
    read = getDappsAddress
    notify = dappsAddressChanged
    write = setDappsAddress

  proc clearPermissions*(self: Web3ProviderView): string {.slot.} =
    self.status.permissions.clearPermissions()

  proc ensResourceURL*(self: Web3ProviderView, ens: string, url: string): string {.slot.} =
    let (url, base, http_scheme, path_prefix, hasContentHash) = self.status.provider.ensResourceURL(ens, url)
    result = url_replaceHostAndAddPath(url, (if hasContentHash: base else: url_host(base)), http_scheme, path_prefix)

  proc replaceHostByENS*(self: Web3ProviderView, url: string, ens: string): string {.slot.} =
    result = url_replaceHostAndAddPath(url, ens)

  proc getHost*(self: Web3ProviderView, url: string): string {.slot.} =
    result = url_host(url)

  proc init*(self: Web3ProviderView) =
    self.setDappsAddress(self.status.settings.getSetting[:string](Setting.DappsAddress))
