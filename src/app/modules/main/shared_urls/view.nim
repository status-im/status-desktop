import NimQml, json, strutils, sequtils

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc parseCommunitySharedUrl*(self: View, url: string): string {.slot.} =
    return self.delegate.parseCommunitySharedUrl(url)

  proc parseCommunityChannelSharedUrl*(self: View, url: string): string {.slot.} =
    return self.delegate.parseCommunityChannelSharedUrl(url)

  proc parseContactSharedUrl*(self: View, url: string): string {.slot.} =
    return self.delegate.parseContactSharedUrl(url)