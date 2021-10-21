import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      dappsAddress: string
      networkId: int

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

  QtProperty[string] networkId:
    read = networkId
    notify = networkIdChanged

  proc replaceHostByENS*(self: View, url: string, ens: string): string {.slot.} =
    result = url_replaceHostAndAddPath(url, ens)

  proc getHost*(self: View, url: string): string {.slot.} =
    result = url_host(url)

