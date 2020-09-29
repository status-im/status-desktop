import NimQml
import chronicles
import ../../../status/profile/profile

QtObject:
  type ProfileInfoView* = ref object of QObject
    username*: string
    identicon*: string
    address*: string
    pubKey*: string
    appearance*: int

  proc setup(self: ProfileInfoView) =
    self.QObject.setup

  proc delete*(self: ProfileInfoView) =
    self.QObject.delete

  proc newProfileInfoView*(): ProfileInfoView =
    new(result, delete)
    result = ProfileInfoView()
    result.pubKey = ""
    result.username = ""
    result.identicon = ""
    result.appearance = 0
    result.setup

  proc profileChanged*(self: ProfileInfoView) {.signal.}

  proc setProfile*(self: ProfileInfoView, profile: Profile) =
    self.username = profile.username
    self.identicon = profile.identicon
    self.appearance = profile.appearance
    self.pubKey = profile.id
    self.address = profile.address
    self.profileChanged()

  proc username*(self: ProfileInfoView): string {.slot.} = result = self.username
  QtProperty[string] username:
    read = username
    notify = profileChanged

  proc appearance*(self: ProfileInfoView): int {.slot.} = result = self.appearance
  proc setAppearance*(self: ProfileInfoView, appearance: int) {.slot.} =
    if self.appearance == appearance:
      return
    self.appearance = appearance
    self.profileChanged()
  QtProperty[int] appearance:
    read = appearance
    write = setAppearance
    notify = profileChanged

  proc identicon*(self: ProfileInfoView): string {.slot.} = result = self.identicon
  QtProperty[string] identicon:
    read = identicon
    notify = profileChanged

  proc pubKey*(self: ProfileInfoView): string {.slot.} = self.pubKey

  QtProperty[string] pubKey:
    read = pubKey
    notify = profileChanged

  proc address*(self: ProfileInfoView): string {.slot.} = self.address

  QtProperty[string] address:
    read = address
    notify = profileChanged
