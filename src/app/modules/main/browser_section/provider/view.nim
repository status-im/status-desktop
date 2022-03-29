import NimQml, strutils

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      dappsAddress: string
      networkId: int
      currentNetwork: string

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc dappsAddressChanged(self: View, value: string) {.signal.}

  proc `dappsAddress=`*(self: View, value: string) =
    self.dappsAddress = value
    self.dappsAddressChanged(value)

  proc dappsAddress*(self: View): string {.slot.} =
    result = self.dappsAddress

  proc setDappsAddress(self: View, value: string) {.slot.} =
    self.delegate.setDappsAddress(value)

  QtProperty[string] dappsAddress:
    read = dappsAddress
    write = setDappsAddress
    notify = dappsAddressChanged

  proc networkIdChanged(self: View, networkId: int) {.signal.}

  proc `networkId=`*(self: View, value: int) =
    self.networkId = value
    self.networkIdChanged(value)

  proc networkId*(self: View): int {.slot.} =
    result = self.networkId

  QtProperty[int] networkId:
    read = networkId
    notify = networkIdChanged

  proc currentNetworkChanged(self: View) {.signal.}

  proc `currentNetwork=`*(self: View, value: string) =
    self.currentNetwork = value
    self.currentNetworkChanged()

  proc currentNetwork*(self: View): string {.slot.} =
    result = self.currentNetwork

  QtProperty[string] currentNetwork:
    read = currentNetwork
    notify = currentNetworkChanged

  proc replaceHostByENS*(self: View, url: string, ens: string): string {.slot.} =
    result = url_replaceHostAndAddPath(url, ens)

  proc getHost*(self: View, url: string): string {.slot.} =
    result = url_host(url)

  proc postMessageResult*(self: View, payloadMethod: string, result: string) {.signal.}

  proc postMessage*(self: View, payloadMethod: string, requestType: string, message: string) {.slot.} =
    self.delegate.postMessage(payloadMethod, requestType, message)

  proc ensResourceURL*(self: View, ens: string, url: string): string {.slot.} =
    let (url, base, http_scheme, path_prefix, hasContentHash) = self.delegate.ensResourceURL(ens, url)
    var newHost = url_host(base)
    if hasContentHash:
      if strutils.endsWith(base, "/"):
        newHost = base[.. ^2]
      else:
        newHost = base

    result = url_replaceHostAndAddPath(url, newHost, http_scheme, "")
