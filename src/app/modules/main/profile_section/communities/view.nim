import NimQml

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

  method inviteUsersToCommunity*(self: View, communityID: string, pubKeysJSON: string, inviteMessage: string): string {.slot.} =
    result = self.delegate.inviteUsersToCommunity(communityID, pubKeysJSON, inviteMessage)

  method leaveCommunity*(self: View, communityID: string) {.slot.} =
    self.delegate.leaveCommunity(communityID)

  method setCommunityMuted*(self: View, communityID: string, mutedType: int) {.slot.} =
    self.delegate.setCommunityMuted(communityID, mutedType)